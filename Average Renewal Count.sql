SELECT AVG("Renewals")
FROM
(
WITH RECURSIVE chain_circ AS
        (
        SELECT circ.id as first_circ, circ.*
        FROM action.all_circulation_slim circ
        WHERE circ.parent_circ IS NULL
            AND circ.xact_start::date>='2023-01-01'
        UNION ALL
        SELECT first_circ, circ2.*
        FROM action.all_circulation_slim circ2
            JOIN chain_circ ON circ2.parent_circ=chain_circ.id
        )
SELECT first_circ as "Initial Circ", count(distinct id)-1 as "Renewals"
FROM chain_circ
GROUP BY 1
ORDER BY 2
) recur_circ