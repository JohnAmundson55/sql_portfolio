SELECT  DISTINCT 
	STRING_AGG(rec6.tag || ' ' || rec6.subfield || ': ' || rec6.value, ' | ' 
		ORDER BY rec6.tag, rec6.subfield) as "6xx",
	STRING_AGG(rec2.tag || ' ' || rec2.subfield || ': ' || rec2.value, ' | ' 
		ORDER BY rec2.tag, rec2.subfield) as "255",
	STRING_AGG(rec0.tag || ' ' || rec0.subfield || ': ' || rec0.value, ' | ' 
		ORDER BY rec0.tag, rec0.subfield) as "034",
	org.name as "Owning Library", loc.name as "Shelving Location", prefix.label as "CN Prefix",
        call.label as "Call Number", suffix.label as "CN Suffix", coalesce(part.label,'') as "Part",
        stat.name as "Copy Status", copy.circ_modifier as "Circ Modifier", copy.barcode as "Barcode",
        call.record as "TCN", title.value as "Title", bib.author as "Author", bib.publisher as "Publisher",
        bib.pubdate as "Published Year", bib.isbn as "ISBN", bib.issn as "ISSN", copy.price as "Price",
        copy.create_date as "Create Date/Time", copy.active_date as "Active Date/Time",
        MAX(circ.xact_start) as "Last Circ in EG", tcirc.circ_Count as "Total Circs",
        call.label_sortkey as "Call Number Sortkey"
FROM asset.copy copy 
        JOIN asset.copy_location loc ON copy.location=loc.id 
        JOIN config.copy_status stat ON copy.status=stat.id 
        JOIN asset.call_number call ON copy.call_number=call.id
        JOIN actor.org_unit org ON call.owning_lib=org.id
        JOIN asset.call_number_prefix prefix ON call.prefix=prefix.id
        JOIN asset.call_number_suffix suffix ON call.suffix=suffix.id
        JOIN reporter.materialized_simple_record bib ON call.record=bib.id
        JOIN metabib.title_field_entry title ON call.record=title.source AND title.field=6
	LEFT JOIN metabib.real_full_rec rec6 ON rec6.record=call.record
		AND rec6.tag ilike '6__' AND rec6.subfield<>'0'
	LEFT JOIN metabib.real_full_rec rec2 ON rec2.record=call.record
		AND rec2.tag='255'
	LEFT JOIN metabib.real_full_rec rec0 ON rec0.record=call.record
		AND rec0.tag='034'
        LEFT JOIN asset.copy_part_map pmap on copy.id=pmap.target_copy
        LEFT JOIN biblio.monograph_part part on pmap.part=part.id
        LEFT JOIN extend_reporter.full_circ_count tcirc on tcirc.id=copy.id
        LEFT JOIN action.circulation circ on circ.target_Copy=copy.id
WHERE copy.deleted='false' AND call.owning_lib=xxx
GROUP BY org.name, call.record, loc.name, prefix.label, 
	call.label, suffix.label,
	part.label, stat.name, 
        copy.circ_modifier, title.value, bib.author, bib.publisher, bib.pubdate, bib.isbn, bib.issn, 
        copy.barcode, copy.price, copy.create_date, copy.active_date, call.label_sortkey, tcirc.circ_count