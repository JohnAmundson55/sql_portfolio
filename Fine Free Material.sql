SELECT count(distinct copy.id) as "Total Copies",
	COUNT(DISTINCT CASE 
		WHEN mat.id IS NOT NULL THEN copy.id 
		WHEN mat.id IS NULL AND mat3.ID IS NULL AND mat2.id IS NOT NULL THEN copy.id
		ELSE NULL  END) as "Fine-Free Copies"
FROM asset.copy
	JOIN asset.call_number call ON call.id=copy.call_number
	/* Fine-free circ mod specific policy*/
		LEFT JOIN config.circ_matrix_matchpoint mat 
	    		ON mat.circ_modifier=copy.circ_modifier
	        			AND mat.recurring_fine_rule=101 AND mat.grp=1
				AND mat.copy_owning_lib=call.owning_lib
	/*Fine-free default policy*/
		LEFT JOIN config.circ_matrix_matchpoint mat2
	    		ON mat2.circ_modifier IS NULL
	        			AND mat2.recurring_fine_rule=101 AND mat2.grp=1
				AND mat2.copy_owning_lib=call.owning_lib
	/* Fine circ mod specific policy*/
		LEFT JOIN config.circ_matrix_matchpoint mat3
	    		ON mat3.circ_modifier=copy.circ_modifier
	        			AND mat3.recurring_fine_rule<>101 AND mat3.grp=1
				AND mat3.copy_owning_lib=call.owning_lib
WHERE copy.deleted=FALSE AND copy.circulate=TRUE