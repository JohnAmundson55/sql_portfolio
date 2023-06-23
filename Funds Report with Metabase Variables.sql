SELECT funds.*, ("Allocated"-"Encumbered"-"Spent") as "Combined Balance",
        CASE WHEN "Allocated"<>0 THEN (CAST("Allocated" as DOUBLE PRECISION)-CAST(("Allocated"-"Encumbered"-"Spent") as DOUBLE PRECISION))/CAST("Allocated" as DOUBLE PRECISION) 
        WHEN ("Allocated"-"Encumbered"-"Spent")<>0 THEN 9.9999 
        ELSE 0 END as "% Used"
FROM(
SELECT distinct fund.year as "Fiscal Year", ou.name as "Fund Library", fund.name as "Fund", fund.code as "Code",
    CASE When allocated<>0 then allocated else 0 end as "Allocated", 
    CASE when encumbered<>0 then encumbered else 0 end as "Encumbered",
    CASE when spent<>0 then spent else 0 end as "Spent"
FROM acq.fund
    JOIN actor.org_unit ON org_Unit.id=fund.org
    LEFT JOIN (SELECT fund, sum(amount) as allocated FROM acq.fund_allocation GROUP BY 1) allocation ON allocation.fund=fund.id
    LEFT JOIN (SELECT fund, sum(amount) as encumbered FROM acq.fund_debit WHERE encumbrance=TRUE GROUP BY 1) deb ON deb.fund=fund.id
    LEFT JOIN (SELECT fund, sum(amount) as spent FROM acq.fund_debit WHERE encumbrance=FALSE GROUP BY 1) deb2 ON deb2.fund=fund.id
    LEFT JOIN actor.org_unit ou ON ou.id=fund.org
    LEFT JOIN acq.fund_tag_map map ON map.fund=fund.id
    LEFT JOIN acq.fund_tag ON fund_tag.id=map.tag
WHERE {{year}} AND {{lib}} AND {{code}} AND {{tag}}
ORDER BY 1,2,3,4
)funds