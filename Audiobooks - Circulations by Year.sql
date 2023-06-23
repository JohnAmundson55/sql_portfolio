SELECT distinct	
	SUM (case when extract(year from circ2.xact_start)='2013' then 1 else 0 end) as "2013",
	SUM (case when extract(year from circ2.xact_start)='2014' then 1 else 0 end) as "2014",
	SUM (case when extract(year from circ2.xact_start)='2015' then 1 else 0 end) as "2015",
	SUM (case when extract(year from circ2.xact_start)='2016' then 1 else 0 end) as "2016",
	SUM (case when extract(year from circ2.xact_start)='2017' then 1 else 0 end) as "2017",
	SUM (case when extract(year from circ2.xact_start)='2018' then 1 else 0 end) as "2018",
	SUM (case when extract(year from circ2.xact_start)='2019' then 1 else 0 end) as "2019",
	SUM (case when extract(year from circ2.xact_start)='2020' then 1 else 0 end) as "2020",
	SUM (case when extract(year from circ2.xact_start)='2021' then 1 else 0 end) as "2021",
	SUM (case when extract(year from circ2.xact_start)='2022' then 1 else 0 end) as "2022",
	copies.*
FROM (SELECT distinct
	tcirc.circ_Count as "Total Circs",
	FIRST(coded_value_map.value) as "Type",
	org.name as "Owning Library", loc.name as "Shelving Location", prefix.label as "CN Prefix",
        	call.label as "Call Number", suffix.label as "CN Suffix", coalesce(part.label,'') as "Part",
        	stat.name as "Copy Status", copy.circ_modifier as "Circ Modifier", copy.barcode as "Barcode",
        	call.record as "TCN", title.value as "Title", bib.author as "Author", 
		bib.publisher as "Publisher",
        	bib.pubdate as "Published Year", bib.isbn as "ISBN", bib.issn as "ISSN", copy.price as "Price",
        	copy.create_date as "Create Date/Time", copy.active_date as "Active Date/Time",
        	MAX(circ.xact_start) as "Last Circ in EG", tcirc.circ_Count as "Total Circ",
        	call.label_sortkey as "Call Number Sortkey", copy.id as id
	FROM asset.copy copy 
        	JOIN asset.copy_location loc ON copy.location=loc.id 
        	JOIN config.copy_status stat ON copy.status=stat.id 
        	JOIN asset.call_number call ON copy.call_number=call.id
        	JOIN actor.org_unit org ON call.owning_lib=org.id
        	JOIN asset.call_number_prefix prefix ON call.prefix=prefix.id
        	JOIN asset.call_number_suffix suffix ON call.suffix=suffix.id
        	JOIN reporter.materialized_simple_record bib ON call.record=bib.id
        	JOIN metabib.title_field_entry title ON call.record=title.source AND title.field=6
        	LEFT JOIN asset.copy_part_map pmap on copy.id=pmap.target_copy
        	LEFT JOIN biblio.monograph_part part on pmap.part=part.id
        	LEFT JOIN extend_reporter.full_circ_count tcirc on tcirc.id=copy.id
        	LEFT JOIN action.circulation circ on circ.target_Copy=copy.id
	LEFT JOIN metabib.record_attr_vector_list vec ON vec.source=bib.id
		LEFT JOIN config.coded_value_map ON coded_value_map.id=ANY(vec.vlist)
			AND ctype='icon_format'
	WHERE copy.deleted='false' AND call.owning_lib=xx 
		AND  coded_value_map.value ilike '%Audiobook%'
	GROUP BY org.name, call.record, loc.name, prefix.label, call.label, suffix.label, part.label, stat.name, 
        	copy.circ_modifier, title.value, bib.author, bib.publisher, bib.pubdate, bib.isbn, bib.issn, 
        	copy.barcode, copy.price, copy.create_date, copy.active_date, 
		call.label_sortkey, tcirc.circ_count, copy.id
	) copies
	LEFT JOIN action.all_circulation circ2 ON circ2.target_copy=copies.id
		AND circ2.xact_start::Date>'2013-01-01'
GROUP BY "Owning Library","Shelving Location","CN Prefix", "Call Number", "CN Suffix", "Part",
        "Copy Status", "Circ Modifier", "Barcode", "TCN", "Title", "Author", "Publisher",
        "Published Year","ISBN","ISSN", "Price", "Create Date/Time", "Active Date/Time",
        "Last Circ in EG", "Total Circs", "Call Number Sortkey", copies.id, "Total Circ", "Type"
ORDER BY "Owning Library","Shelving Location","CN Prefix", "Call Number Sortkey", "CN Suffix", "Part"