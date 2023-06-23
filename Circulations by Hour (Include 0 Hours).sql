WITH RECURSIVE 
	mycte as
    		(SELECT 0 AS MyHour
    		UNION ALL
    		SELECT MyHour + 1
    		FROM mycte 
    		WHERE MyHour + 1 < 24),
	mycte2 as 
    		(SELECT 0 as MyDay
    		UNION ALL
    		SELECT MyDay + 1
    		FROM mycte2 
    		WHERE MyDay + 1 < 7),
	mycte3 as
		(SELECT 1 as MyMonth
		UNION ALL
		SELECT MyMonth + 1
		FROM mycte3
		WHERE MyMonth + 1 < 13)
SELECT distinct workstation.name as "Workstation", 
	mycte3.MyMonth as "Checkin Month", 
	mycte2.MyDay as "Day of Week", 
	mycte.MyHour as "Hour of Day",
	COALESCE("Circs",0) as "Checkins"
FROM mycte
	CROSS JOIN mycte2
	CROSS JOIN mycte3
	CROSS JOIN actor.workstation
	LEFT JOIN
		(SELECT circ.checkin_workstation, extract(month from circ.checkin_scan_time) as cmonth,
			extract(dow from circ.checkin_scan_time) as dow1, 
			extract (hour from circ.checkin_scan_time) as hour1,
        		count(distinct circ.id) as "Circs"
		FROM action.all_circulation circ
		WHERE circ.checkin_lib IN (xxx,yyy)
			AND circ.checkin_scan_time::date between '2022-01-01' and '2022-12-31'
		GROUP BY 1,2,3,4
		) cir ON cmonth=MyMonth AND dow1=MyDay AND hour1=MyHour 
				AND workstation.id=cir.checkin_workstation
WHERE workstation.owning_lib in (xxx,yyy) 
	AND workstation.id NOT IN (aaaa,bbbb)
ORDER BY 1,2,3,4