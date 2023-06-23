WITH max_card AS (	SELECT MAX(card.id) as card_id
			FROM actor.card
				JOIN actor.usr ON usr.card=card.id
			WHERE usr.create_date::date='2020-06-30'
		  )
, min_card AS  (	SELECT MIN(card.id) as card_id
			FROM actor.card
				JOIN actor.usr ON usr.card=card.id
			WHERE usr.create_date::date='2020-03-16'
		  )
SELECT count(distinct card.id)
FROM actor.card
	CROSS JOIN max_card
	CROSS JOIN min_card
WHERE card.id BETWEEN min_card.card_id AND max_card.card_id AND card.barcode ilike 'xxxx%'