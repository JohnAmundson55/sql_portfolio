SELECT org_unit.name as "LIBRARY",
        (case when dow_6_close = '0:00:00' and dow_6_open = '0:00:00' then 'CLOSED'
            WHEN dow_6_open<'12:00' AND dow_6_close>='12:00' THEN CONCAT(to_char(dow_6_open, 'hh12')::integer,':', to_char(dow_6_open, 'mi'), 'AM - ', to_char(dow_6_close, 'hh12')::integer,':', to_char(dow_6_close, 'mi'),'PM') 
            WHEN dow_6_open<'12:00' AND dow_6_close<'12:00' THEN CONCAT(to_char(dow_6_open, 'hh12')::integer,':', to_char(dow_6_open, 'mi'), 'AM - ', to_char(dow_6_close, 'hh12')::integer,':', to_char(dow_6_close, 'mi'),'AM')
            WHEN dow_6_open>='12:00' AND dow_6_close>='12:00' THEN CONCAT(to_char(dow_6_open, 'hh12')::integer,':', to_char(dow_6_open, 'mi'), 'PM - ', to_char(dow_6_close, 'hh12')::integer,':', to_char(dow_6_close, 'mi'),'PM')
            else ' ' end) as "SUNDAY",
        (case when dow_0_close = '0:00:00' and dow_0_open = '0:00:00' then 'CLOSED' 
            WHEN dow_0_open<'12:00' AND dow_0_close>='12:00' THEN CONCAT(to_char(dow_0_open, 'hh12')::integer,':', to_char(dow_0_open, 'mi'), 'AM - ', to_char(dow_0_close, 'hh12')::integer,':', to_char(dow_0_close, 'mi'),'PM') 
            WHEN dow_0_open<'12:00' AND dow_0_close<'12:00' THEN CONCAT(to_char(dow_0_open, 'hh12')::integer,':', to_char(dow_0_open, 'mi'), 'AM - ', to_char(dow_0_close, 'hh12')::integer,':', to_char(dow_0_close, 'mi'),'AM')
            WHEN dow_0_open>='12:00' AND dow_0_close>='12:00' THEN CONCAT(to_char(dow_0_open, 'hh12')::integer,':', to_char(dow_0_open, 'mi'), 'PM - ', to_char(dow_0_close, 'hh12')::integer,':', to_char(dow_0_close, 'mi'),'PM')
            else ' ' end) as "MONDAY",
        (case when dow_1_close = '0:00:00' and dow_1_open = '0:00:00' then 'CLOSED'
            WHEN dow_1_open<'12:00' AND dow_1_close>='12:00' THEN CONCAT(to_char(dow_1_open, 'hh12')::integer,':', to_char(dow_1_open, 'mi'), 'AM - ', to_char(dow_1_close, 'hh12')::integer,':', to_char(dow_1_close, 'mi'),'PM') 
            WHEN dow_1_open<'12:00' AND dow_1_close<'12:00' THEN CONCAT(to_char(dow_1_open, 'hh12')::integer,':', to_char(dow_1_open, 'mi'), 'AM - ', to_char(dow_1_close, 'hh12')::integer,':', to_char(dow_1_close, 'mi'),'AM')
            WHEN dow_1_open>='12:00' AND dow_1_close>='12:00' THEN CONCAT(to_char(dow_1_open, 'hh12')::integer,':', to_char(dow_1_open, 'mi'), 'PM - ', to_char(dow_1_close, 'hh12')::integer,':', to_char(dow_1_close, 'mi'),'PM')
            else ' ' end) as "TUESDAY",
        (case when dow_2_close = '0:00:00' and dow_2_open = '0:00:00' then 'CLOSED'
            WHEN dow_2_open<'12:00' AND dow_2_close>='12:00' THEN CONCAT(to_char(dow_2_open, 'hh12')::integer,':', to_char(dow_2_open, 'mi'), 'AM - ', to_char(dow_2_close, 'hh12')::integer,':', to_char(dow_2_close, 'mi'),'PM') 
            WHEN dow_2_open<'12:00' AND dow_2_close<'12:00' THEN CONCAT(to_char(dow_2_open, 'hh12')::integer,':', to_char(dow_2_open, 'mi'), 'AM - ', to_char(dow_2_close, 'hh12')::integer,':', to_char(dow_2_close, 'mi'),'AM')
            WHEN dow_2_open>='12:00' AND dow_2_close>='12:00' THEN CONCAT(to_char(dow_2_open, 'hh12')::integer,':', to_char(dow_2_open, 'mi'), 'PM - ', to_char(dow_2_close, 'hh12')::integer,':', to_char(dow_2_close, 'mi'),'PM')
            else ' ' end) as "WEDNESDAY",
        (case when dow_3_close = '0:00:00' and dow_3_open = '0:00:00' then 'CLOSED'
            WHEN dow_3_open<'12:00' AND dow_3_close>='12:00' THEN CONCAT(to_char(dow_3_open, 'hh12')::integer,':', to_char(dow_3_open, 'mi'), 'AM - ', to_char(dow_3_close, 'hh12')::integer,':', to_char(dow_3_close, 'mi'),'PM') 
            WHEN dow_3_open<'12:00' AND dow_3_close<'12:00' THEN CONCAT(to_char(dow_3_open, 'hh12')::integer,':', to_char(dow_3_open, 'mi'), 'AM - ', to_char(dow_3_close, 'hh12')::integer,':', to_char(dow_3_close, 'mi'),'AM')
            WHEN dow_3_open>='12:00' AND dow_3_close>='12:00' THEN CONCAT(to_char(dow_3_open, 'hh12')::integer,':', to_char(dow_3_open, 'mi'), 'PM - ', to_char(dow_3_close, 'hh12')::integer,':', to_char(dow_3_close, 'mi'),'PM')
            else ' ' end) as "THURSDAY",
        (case when dow_4_close = '0:00:00' and dow_4_open = '0:00:00' then 'CLOSED'
            WHEN dow_4_open<'12:00' AND dow_4_close>='12:00' THEN CONCAT(to_char(dow_4_open, 'hh12')::integer,':', to_char(dow_4_open, 'mi'), 'AM - ', to_char(dow_4_close, 'hh12')::integer,':', to_char(dow_4_close, 'mi'),'PM') 
            WHEN dow_4_open<'12:00' AND dow_4_close<'12:00' THEN CONCAT(to_char(dow_4_open, 'hh12')::integer,':', to_char(dow_4_open, 'mi'), 'AM - ', to_char(dow_4_close, 'hh12')::integer,':', to_char(dow_4_close, 'mi'),'AM')
            WHEN dow_4_open>='12:00' AND dow_4_close>='12:00' THEN CONCAT(to_char(dow_4_open, 'hh12')::integer,':', to_char(dow_4_open, 'mi'), 'PM - ', to_char(dow_4_close, 'hh12')::integer,':', to_char(dow_4_close, 'mi'),'PM')
            else ' ' end) as "FRIDAY",
        (case when dow_5_close = '0:00:00' and dow_5_open = '0:00:00' then 'CLOSED'
            WHEN dow_5_open<'12:00' AND dow_5_close>='12:00' THEN CONCAT(to_char(dow_5_open, 'hh12')::integer,':', to_char(dow_5_open, 'mi'), 'AM - ', to_char(dow_5_close, 'hh12')::integer,':', to_char(dow_5_close, 'mi'),'PM') 
            WHEN dow_5_open<'12:00' AND dow_5_close<'12:00' THEN CONCAT(to_char(dow_5_open, 'hh12')::integer,':', to_char(dow_5_open, 'mi'), 'AM - ', to_char(dow_5_close, 'hh12')::integer,':', to_char(dow_5_close, 'mi'),'AM')
            WHEN dow_5_open>='12:00' AND dow_5_close>='12:00' THEN CONCAT(to_char(dow_5_open, 'hh12')::integer,':', to_char(dow_5_open, 'mi'), 'PM - ', to_char(dow_5_close, 'hh12')::integer,':', to_char(dow_5_close, 'mi'),'PM')
            else ' ' end) as "SATURDAY"
FROM actor.org_unit 
        LEFT JOIN actor.hours_of_operation hours ON org_unit.id=hours.id 
WHERE ou_type=x AND org_unit.id not in (xxx,yyy)
ORDER BY org_unit.name
