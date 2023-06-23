SELECT org_unit.name as "Pickup Location", ROW_NUMBER() OVER(ORDER BY hold_counts DESC) AS "Rank",  
    CONCAT('https://catalog.cwmars.org/opac/extras/ac/jacket/large/r/', bib_id) as "Cover Art",
    bib.author as "Author", bib.title as "Title", maps.format as "Format", bib.isbn[array_length(bib.isbn, 1)] as "ISBN",
    bib.id as "TCN",
    [[CASE WHEN {{ratio}} ilike 'y%'
            THEN ROUND(COALESCE(hold_counts,0)::decimal/COALESCE(copy_counts,1),2)
        ELSE 0 END as "LH:LC",]]
    [[CASE WHEN {{ratio}} ilike 'y%'
            THEN ROUND(COALESCE(hold_total,0)::decimal/COALESCE(copy_total,1),2)
        ELSE 0 END as "CH:CC",]]
    [[CASE WHEN {{ratio}} ilike 'y%'
            THEN ROUND(COALESCE(hold_counts,0)::decimal/COALESCE(copy_total,1),2)
        ELSE 0 END as "LH:CC",]]
    [[CASE WHEN {{ratio}} ilike 'y%'
            THEN ROUND(COALESCE(copy_counts,0)::decimal/COALESCE(copy_total,1),2)
        ELSE 0 END as "LC:CC",]]
    COALESCE(copy_total,0) as "CW MARS Copies", COALESCE(copy_counts,0) as "Local Copies",
    COALESCE(hold_total) as "CW MARS Holds", COALESCE(hold_counts,0) as "Local Holds",
    CONCAT('https://catalog.cwmars.org/eg/opac/record/', bib_id) as "Bib Record Link",
    CONCAT('https://catalog.cwmars.org/eg/opac/results?query=', bib.title, '&qtype=title') as "Title Search"
FROM dashboard.library_high_use
    JOIN actor.org_unit ON org_unit.id=library_high_use.org_unit
    LEFT JOIN reporter.materialized_simple_record bib ON bib_id=bib.id
    LEFT JOIN 
        (   SELECT vec.source as bibs_id, FIRST(coded_Value_map.value) as format
            FROM dashboard.library_high_use lib_high 
                JOIN metabib.record_attr_vector_list vec ON vec.source=lib_high.bib_id
		        JOIN config.coded_value_map ON coded_value_map.id=ANY(vec.vlist)
			WHERE ctype='icon_format'
			GROUP BY 1
		) maps ON maps.bibs_id=bib.id
WHERE {{lib}} AND {{format}} [[AND bib.author ilike CONCAT('%',{{author}},'%')]]
ORDER BY "Rank", hold_counts desc, copy_counts