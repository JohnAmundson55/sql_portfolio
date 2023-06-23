SELECT  items.* 
FROM (
    SELECT distinct on (copy.id) org_unit.name as "Owning Library", copy_location.name as "Shelving Location", 
        call_number_prefix.label as "CN Prefix", call.label as "Call Number", call_number_suffix.label as "CN Suffix", coalesce(part.label,'') as "Part",
        copy_status.name as "Item Status", circ_modifier.name as "Circ Modifier", copy.barcode as "Barcode",
        call.record as "TCN", CONCAT('https://catalog.cwmars.org/opac/extras/ac/jacket/large/r/',call.record) as "Cover",
        title.value as "Title", bib.author as "Author", bib.publisher as "Publisher",
        bib.pubdate as "Published Year", bib.isbn as "ISBN", bib.issn as "ISSN", copy.price as "Price",
        copy.create_date as "Create Date/Time", copy.active_date as "Active Date/Time",
        copy.status_changed_time as "Item Status Change Date/Time", copy.edit_date as "Last Edit Date/Time",
        MAX(circulation.xact_start) as "Last Circ in EG", full_circ_count.circ_Count as "Total Circs",
        COUNT(distinct cyc.id) as "CY Circs", COUNT(distinct pyc.id) as "PY Circs",
        [[CASE WHEN bool_or({{xact_start}}) THEN Count(distinct all_circulation_slim.id) ELSE 0 END as "Period Circs",]]
        [[CASE WHEN bool_or({{xact_start}}) THEN MIN(all_circulation_slim.xact_start) ELSE MIN(all_circulation_slim.xact_start) END as "First Period Circ",]]
        [[CASE WHEN bool_or({{xact_start}}) THEN MAX(all_circulation_slim.xact_start) ELSE MAX(all_circulation_slim.xact_start) END as "Last Period Circ",]]
        CASE WHEN MAX(copy_alert.id) IS NOT NULL THEN CONCAT(LAST(CONCAT(type.name, ' - ', copy_alert.note)),' (',count(distinct copy_alert.id)::varchar,')') 
            ELSE '' END as "Recent Item Alert (Total)",
        FIRST(coded_value_map.value) as "Catalog Icon",
        aa.value as "AR Age", af.value as "AR Format", cw.value as "MARS Format", 
        FIRST(CONCAT(li.name,'-',li.value)) as "Library StatCat",
        latest_inventory.inventory_date as "Latest Inventory Date/Time", ws.name as "Inventory Workstation",
        FIRST(oclc.value) as "OCLC #", 
        call.label_sortkey as "Call Number Sortkey", 
        copy.deleted as "Deleted?", 
        copy.id as "Item ID"
    FROM asset.copy
            JOIN asset.copy_location ON copy.location=copy_location.id 
            JOIN config.copy_status ON copy.status=copy_status.id
            JOIN config.circ_modifier ON circ_modifier.code=copy.circ_modifier
            JOIN asset.call_number call ON copy.call_number=call.id
                JOIN actor.org_unit ON call.owning_lib=org_unit.id
                JOIN asset.call_number_prefix ON call.prefix=call_number_prefix.id
                JOIN asset.call_number_suffix ON call.suffix=call_number_suffix.id
            JOIN reporter.materialized_simple_record bib ON call.record=bib.id
                JOIN metabib.title_field_entry title ON call.record=title.source AND title.field=6
            LEFT JOIN asset.copy_part_map pmap on copy.id=pmap.target_copy
                LEFT JOIN biblio.monograph_part part on pmap.part=part.id
            LEFT JOIN extend_reporter.full_circ_count on full_circ_count.id=copy.id
                LEFT JOIN action.circulation ON circulation.target_copy=copy.id
                LEFT JOIN extend_reporter.dusty_titles ON dusty_titles.id=copy.id
                LEFT JOIN action.all_circulation_slim cyc ON cyc.target_copy=copy.id 
                    AND extract(year from cyc.xact_start)=extract(year from now())
                LEFT JOIN action.all_circulation_slim pyc ON pyc.target_copy=copy.id
                    AND extract(year from pyc.xact_start)=(extract(year from now())-1)
            LEFT JOIN asset.latest_inventory ON latest_inventory.copy=copy.id
                LEFT JOIN actor.workstation ws ON ws.id=latest_inventory.inventory_workstation
            LEFT JOIN metabib.record_attr_vector_list vec ON vec.source=bib.id
    		    LEFT JOIN config.coded_value_map ON coded_value_map.id=ANY(vec.vlist)
    			    AND {{ci}} 
            LEFT JOIN metabib.real_full_rec oclc ON oclc.record=call.record 
    		    AND oclc.tag='035' AND oclc.subfield='a' AND oclc.value ilike '%o%c%l%c%'
    		LEFT JOIN asset.copy_alert ON copy_alert.copy=copy.id
    		    AND copy_alert.ack_time IS NULL
    		    LEFT JOIN config.copy_alert_type type ON type.id=copy_alert.alert_type
            LEFT JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    			    AND {{af}} AND {{ar_form}}) af
    		    ON copy.id=af.owning_copy
    	    LEFT JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    			    AND {{aa}} AND {{ar_age}}) aa
    		    ON copy.id=aa.owning_copy
    		LEFT JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    			    AND {{cw}} AND {{cw_form}}) cw
    		    ON copy.id=cw.owning_copy
    		LEFT JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    		    JOIN asset.stat_cat ON stat_cat.id=stat_cat_entry.stat_cat
    			   AND map.stat_cat>3 AND {{li_stat}} AND {{li_stat_ent}}) li
    		    ON copy.id=li.owning_copy
            [[LEFT JOIN action.all_circulation_slim ON all_circulation_slim.target_copy=copy.id
                        AND {{xact_start}} 
                        [[AND CASE WHEN {{circt}} ilike '%home%' THEN all_circulation_slim.circ_lib=call.owning_lib
                                    WHEN {{circt}} ilike '%away%' THEN all_circulation_slim.circ_lib<>call.owning_lib
                                    ELSE all_circulation_slim.id IS NOT NULL END]]]]
    WHERE {{owning_lib}} 
        AND {{copy_loc}} AND {{circ_mod}} AND {{status}}
        AND {{create_date}} AND {{active_date}} AND {{status_change}} AND {{last_edit}} AND {{inven_date}} 
        AND {{catalog_icon}} AND {{cn_pre}} AND {{cn_suf}}
        [[AND copy.barcode ilike CONCAT({{bar_pre}},'%')]]
        [[AND COALESCE(bib.pubdate::varchar,extract(year from copy.create_date)::varchar) between {{pubdate1}}::varchar and {{pubdate2}}::varchar]]
        [[AND UPPER({{deleted}}::varchar)=UPPER(copy.deleted::varchar)]]
        [[AND UPPER({{loc_del}}::varchar)=UPPER(copy_location.deleted::varchar)]]
        [[AND full_circ_count.circ_count<={{total_circs}}]] 
        [[AND full_circ_count.circ_count>={{total_circs2}}]] 
        [[AND UPPER(call.label_sortkey) BETWEEN UPPER({{call1}}) AND UPPER({{call2}})]] 
        [[AND call.label_sortkey ilike CONCAT('%',{{call3}},'%')]]
        [[AND CASE WHEN LOWER({{last_circ}})::varchar ~* LOWER('(year|day|month|hour|minute)') THEN dusty_titles.last_checkout::date<=(now()::date - LOWER({{last_circ}})::interval)
            ELSE dusty_titles.last_checkout::date<={{last_circ}}::date END]]
        [[AND {{build_list}} ilike 'build list']]
    GROUP BY "Owning Library", "Shelving Location", "CN Prefix",
            "Call Number", "CN Suffix", "Part",
            "Item Status", "Circ Modifier",  "Barcode", "Cover",
            "TCN", "Title", "Author", "Publisher",
            "Published Year","ISBN", "ISSN", "Price",
            "Create Date/Time", "Active Date/Time",
            "Item Status Change Date/Time", "Last Edit Date/Time","Latest Inventory Date/Time",
            "Total Circs", "AR Age", "AR Format","Inventory Workstation",
            "Call Number Sortkey", "Deleted?", "Item ID", "MARS Format"
    HAVING MAX(copy.create_date)::date<=(now()::date + interval '10 minutes')
        [[AND count(distinct all_circulation_slim.id)<={{per_circs}}]]
        [[AND count(distinct all_circulation_slim.id)>={{per_Circs2}}]]
    ORDER BY copy.id, latest_inventory.inventory_date desc
) items
    [[JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    			    AND map.stat_cat=1 AND {{ar_form}}) af
    	ON items."Item ID"=af.owning_copy]]
    [[JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    			    AND map.stat_cat=2 AND {{ar_age}}) aa
    	ON items."Item ID"=aa.owning_copy]]
    [[JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id
    			    AND map.stat_cat=3 AND {{cw_form}}) cw
        ON items."Item ID"=cw.owning_copy]]
    [[JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id 
    		    JOIN asset.stat_cat On stat_cat.id=stat_cat_entry.stat_cat
    			    AND map.stat_cat>3 AND {{li_stat}}) li
    	ON items."Item ID"=li.owning_copy]]
    [[JOIN (asset.stat_cat_entry_copy_map map
    		    JOIN asset.stat_cat_entry ON map.stat_cat_entry=stat_cat_entry.id 
    		    JOIN asset.stat_cat On stat_cat.id=stat_cat_entry.stat_cat
    			    AND map.stat_cat>3 AND {{li_stat_ent}}) lie
    	ON items."Item ID"=lie.owning_copy]]
WHERE "Item ID">0 [[AND CASE WHEN LOWER({{last_inven}})::varchar ~* LOWER('(year|day|month|hour|minute)') THEN COALESCE("Latest Inventory Date/Time","Create Date/Time")::date<=now()::date - LOWER({{last_inven}})::interval
             ELSE COALESCE("Latest Inventory Date/Time","Create Date/Time")::date<={{last_inven}}::date END]] [[AND "Recent Item Alert (Total)" ilike CONCAT('%',{{alert_contents}},'%')]]
ORDER BY "Owning Library", "Shelving Location", "CN Prefix", "Call Number Sortkey", "CN Suffix", "Part", "Author", "Title"