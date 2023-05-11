-- VÝCHOZÍ TABULKY

-- Primární tabulka

CREATE OR REPLACE TABLE t_radek_v_project_sql_primary_final AS (
	WITH payroll AS (
		SELECT
			`industry_branch_code`,
			CASE
				WHEN cpib.`name` IS NULL THEN 'Všechna odvětví'
				ELSE cpib.`name`
			END `industry_branch_name`,
			cp.`payroll_year`,
			ROUND(AVG(cp.`value`)) `payroll_avg`,
			cpu.`name` `payroll_unit`
		FROM czechia_payroll cp
		LEFT JOIN czechia_payroll_industry_branch cpib
			ON cp.`industry_branch_code` = cpib.`code`
		JOIN czechia_payroll_unit cpu
			ON cp.`unit_code`= cpu.`code`
		WHERE	
			cp.`payroll_year` < 2021
			AND cp.`value_type_code` = 5958
			AND cp.`calculation_code` = 200
		GROUP BY
			cp.`industry_branch_code`,
			cp.`payroll_year`
	),
	price AS (
		SELECT
			cpc.`name` `product_category_name`,
			YEAR(cp.`date_from`) `price_year`,
			ROUND(AVG(cp.`value`), 2) `price_avg`,
			'Kč' `price_unit`
		FROM czechia_price cp
		JOIN czechia_price_category cpc
			ON cp.`category_code` = cpc.`code`
		WHERE `region_code` IS NULL
		GROUP BY
			cp.`category_code`,
			`price_year`
	),
	economy AS (
		SELECT
			`year` `GDP_year`,
			`GDP`,
			'USD' `GDP_unit`
		FROM economies e
		WHERE
			`year` > 1999
			AND `country` = 'Czech republic'
	)
	SELECT
		pa.`industry_branch_name`,
		pa.`payroll_year` `year`,
		pa.`payroll_avg`,
		pa.`payroll_unit`,
		pr.`product_category_name`,
		pr.`price_avg`,
		pr.`price_unit`,
		e.`GDP`,
		e.`GDP_unit`
	FROM payroll pa
	LEFT JOIN price pr
		ON
			pa.`payroll_year` = pr.`price_year`
			AND pa.`industry_branch_name` = 'Všechna odvětví'
	LEFT JOIN economy e
		ON
			pa.`payroll_year` = e.`GDP_year`
			AND pa.`industry_branch_name` = 'Všechna odvětví'
	ORDER BY
		pa.`industry_branch_code`,
		`year`,
		pr.`product_category_name`
);

SELECT
	*
FROM t_radek_v_project_sql_primary_final trvpspf;

-- Sekundární tabulka

CREATE OR REPLACE TABLE t_radek_v_project_SQL_secondary_final AS (
	SELECT
		e.`country`,
		e.`year`,
		e.`GDP`,
		e.`gini`,
		e.`population`
	FROM countries c
	LEFT JOIN economies e
		ON c.`country` = e.`country`
	WHERE
		c.`continent` = 'Europe'
		AND e.`year` > 1999
	ORDER BY
		e.`country`,
		e.`year`
);

SELECT
	*
FROM t_radek_v_project_sql_secondary_final trvpssf;

-- OTÁZKA 1.

-- OTÁZKA 2.

-- OTÁZKA 3.

-- OTÁZKA 4.

-- OTÁZKA 5.