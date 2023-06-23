SELECT distinct extract(year from pay_ts) as "Year",
	sum("Amount Collected") as "Fines Collected"
FROM (
	SELECT distinct pay.amount as "Amount Collected",
		circ.id as "Circ Transaction ID", pay.id as "Payment ID", pay.payment_ts as pay_ts
	FROM action.all_circulation_slim circ
		JOIN asset.copy ON copy.id=circ.target_copy  
		JOIN asset.call_number call ON call.id=copy.call_number
		JOIN money.payment_view pay ON pay.xact=circ.id
		JOIN money.billing bill ON bill.xact=circ.id
		LEFT JOIN money.billing bill2 ON bill2.xact=circ.id
			AND bill2.btype IN (3,4) AND bill.voided=FALSE
		LEFT JOIN money.cash_payment cash ON cash.id=pay.id
			LEFT JOIN actor.workstation ws_cash ON ws_cash.id=cash.cash_drawer
			LEFT JOIN actor.org_unit ou_cash ON ou_cash.id=ws_cash.owning_lib
		LEFT JOIN money.check_payment checks ON checks.id=pay.id
			LEFT JOIN actor.workstation ws_check ON ws_check.id=checks.cash_drawer
			LEFT JOIN actor.org_unit ou_check ON ou_check.id=ws_check.owning_lib
		LEFT JOIN money.credit_card_payment credit ON credit.id=pay.id
			LEFT JOIN actor.workstation ws_credit ON ws_credit.id=credit.cash_drawer
			LEFT JOIN actor.org_unit ou_credit ON ou_credit.id=ws_credit.owning_lib
		LEFT JOIN money.billable_xact_summary xact on xact.id=circ.id
	WHERE pay.voided=FALSE AND bill.btype=1 AND bill.voided=FALSE
		AND pay.payment_type IN ('cash_payment','check_payment','credit_card_payment')
		AND pay.payment_ts>bill.billing_ts 
		AND (pay.payment_ts<bill2.billing_ts OR pay.payment_ts>checkin_time
			OR bill2.id IS NULL)
		AND pay.payment_ts::date between '2017-01-01' and '2022-12-31'
		AND (ou_check.id=xx 
			OR ou_cash.id=xx
			OR (pay.payment_type='credit_card_payment' AND 
				((ou_credit.id IS NULL AND call.owning_lib=xx)
					OR ou_credit.id=xx)))
	) pays
GROUP BY 1