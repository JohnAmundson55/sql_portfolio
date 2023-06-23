BEGIN;
DELETE FROM dashboard.stats 
	WHERE fiscal_year=extract(year from now()) AND org_unit=1 AND type='cc';
COMMIT;


BEGIN;

INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Number of Bibliographic Records', '', count(distinct tcn.id), 'tc'
FROM biblio.record_entry tcn		
	WHERE deleted=FALSE
		AND ((extract(year from tcn.create_date)=extract(year from now()) 
			AND extract(month from tcn.create_date)<7)
		OR (extract(year from tcn.create_date)<extract(year from now())));

INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Number of Online Resources for Local Use', '', count(distinct tcn.id), 'tc'	
FROM asset.call_Number call
	JOIN biblio.record_entry tcn ON tcn.id=call.record
	LEFT JOIN (asset.call_number call3
			JOIN asset.copy ON copy.call_number=call3.id
				AND copy.deleted=FALSE) call2 ON call2.record=tcn.id
WHERE call.deleted=false AND call.label='##URI##' AND tcn.deleted=false
	AND call2.record IS NULL
	AND ((extract(year from tcn.create_date)=extract(year from now()) 
			AND extract(month from tcn.create_date)<7)
		OR (extract(year from tcn.create_date)<extract(year from now())));

INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Item Counts', '', count(distinct copy.id), 'cc'	
FROM asset.copy
WHERE copy.deleted=FALSE
	AND ((extract(year from copy.create_date)=extract(year from now()) 
			AND extract(month from copy.create_date)<7)
		OR (extract(year from copy.create_date)<extract(year from now())));

INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Initial Checkouts', '', count(distinct circ.id), 'ci'
FROM action.all_circulation circ
WHERE ((extract(year from circ.xact_start)=extract(year from now()) 
			AND extract(month from circ.xact_start)<7)
		OR (extract(year from circ.xact_start)=(extract(year from now())-1)
			AND extract(month from circ.xact_start)>=7))
	AND parent_circ is NULL;
	
INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Renewals', '', count(distinct circ.id), 'ci'
FROM action.all_circulation circ
WHERE ((extract(year from circ.xact_start)=extract(year from now()) 
			AND extract(month from circ.xact_start)<7)
		OR (extract(year from circ.xact_start)=(extract(year from now())-1)
			AND extract(month from circ.xact_start)>=7))
	AND parent_circ is NOT NULL;
	
INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Network Transfers (Renewals)', '', count(distinct circ.id), 'nt'
FROM action.all_circulation circ
	JOIN actor.org_unit ouc ON ouc.id=circ.circ_lib
	JOIN actor.org_unit oui ON oui.id=circ.copy_owning_lib
WHERE ((extract(year from circ.xact_start)=extract(year from now()) 
			AND extract(month from circ.xact_start)<7)
		OR (extract(year from circ.xact_start)=(extract(year from now())-1)
			AND extract(month from circ.xact_start)>=7))
	AND oui.parent_ou<>ouc.parent_ou AND parent_circ is NOT NULL;
	
INSERT INTO dashboard.stats (fiscal_year, org_unit, heading, description, count, type)
SELECT extract(year from now()), 1, 'Network Transfers (Initial Checkouts)', '', count(distinct circ.id), 'nt'
FROM action.all_circulation circ
	JOIN actor.org_unit ouc ON ouc.id=circ.circ_lib
	JOIN actor.org_unit oui ON oui.id=circ.copy_owning_lib
WHERE ((extract(year from circ.xact_start)=extract(year from now()) 
			AND extract(month from circ.xact_start)<7)
		OR (extract(year from circ.xact_start)=(extract(year from now())-1)
			AND extract(month from circ.xact_start)>=7))
	AND oui.parent_ou<>ouc.parent_ou AND parent_circ is NULL;



COMMIT;