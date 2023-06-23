SELECT distinct CASE WHEN copy.deleted THEN 'Yes' ELSE 'No' END as "Deleted?", 
    CASE WHEN copy.call_number=-1 THEN 'Yes' ELSE 'No' END as "Precat?", 
    CASE WHEN circ.xact_finish IS NOT NULL THEN 'Yes (Paid)' WHEN circ.id IS NOT NULL THEN 'Yes' ELSE 'No' END as "Checked Out?", 
    copy.id as "Item ID", stat.name as "Item Status",
    copy.barcode as "Current Barcode", asset_copy_lifecycle.barcode as "Entered Barcode", 
    CASE WHEN bib.id=-1 THEN 'N/A' ELSE bib.id::varchar END as "TCN", 
    CASE WHEN bib.id=-1 THEN copy.dummy_author ELSE bib.author END as "Author",
    CASE WHEN bib.id=-1 THEN copy.dummy_title ELSE bib.title END as "Title", coalesce(part.label,'') as "Part",
    ouo.shortname as "Owning Lib", ouc.shortname as "Circulating Lib",
    copy.circ_modifier as "Circ Modifier", copy.edit_date as "Date/Time Last Edited",
    CONCAT('https://bark.cwmars.org/eg/staff/cat/item/',copy.id) as "Evergreen URL"
FROM asset.copy
    JOIN auditor.asset_copy_lifecycle ON asset_copy_lifecycle.id=copy.id
    JOIN asset.call_number call ON call.id=copy.call_number
    JOIN actor.org_unit ouo ON call.owning_lib=ouo.id
    JOIN actor.org_unit ouc ON copy.circ_lib=ouc.id
    JOIN reporter.materialized_simple_record bib ON call.record=bib.id
    JOIN config.copy_status stat ON copy.status=stat.id 
    LEFT JOIN asset.copy_part_map pmap on copy.id=pmap.target_copy
        LEFT JOIN biblio.monograph_part part on pmap.part=part.id
    LEFT JOIN action.circulation circ ON circ.target_copy=copy.id 
        AND circ.checkin_time IS NULL 
WHERE {{barcode}}
Order by "Entered Barcode", "Item ID" desc