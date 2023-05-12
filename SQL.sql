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
			'Kč' `price_unit`,
			cpc.`price_value`,
			cpc.`price_unit` `price_value_unit`
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
		pr.`price_value`,
		pr.`price_value_unit`,
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

SELECT
	`industry_branch_name`,
	`year`,
	`payroll_avg`,
	`payroll_unit`
FROM t_radek_v_project_sql_primary_final trvpspf
GROUP BY
	`industry_branch_name`,
	`year`;

-- OTÁZKA 2.

SELECT
	`industry_branch_name`,
	`YEAR`,
	`payroll_avg`,
	`payroll_unit`,
	`product_category_name`,
	`price_avg`,
	`price_unit`,
	`price_value`,
	`price_value_unit`,
	ROUND(`payroll_avg` / `price_avg`) `payroll_unit / price_unit`
FROM t_radek_v_project_sql_primary_final trvpspf
WHERE 
	`product_category_name` IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
	AND `year` IN (2006, 2018)
ORDER BY
	`product_category_name`,
	`year`;

-- OTÁZKA 3.

SELECT
	t.`product_category_name`,
	ROUND(AVG((t.`price_avg` / t2.`price_avg` - 1) * 100), 2) `avg_year_on_year_increase_%`
FROM t_radek_v_project_sql_primary_final t
JOIN t_radek_v_project_sql_primary_final t2
	ON
		t.`product_category_name` = t2.`product_category_name`
		AND t.`year` = t2.`year` + 1
GROUP BY t.`product_category_name`
ORDER BY `avg_year_on_year_increase_%`;

-- OTÁZKA 4.

WITH payroll_price AS (
	SELECT
		`year`,
		`payroll_avg`,
		`payroll_unit`,
		ROUND(AVG(`price_avg`), 2) `price_total_avg`,
		`price_unit`
	FROM t_radek_v_project_sql_primary_final t
	WHERE
		`year` BETWEEN 2006 AND 2018
		AND `industry_branch_name` = 'Všechna odvětví'
	GROUP BY `year`
)
SELECT
	p.`year` `current_year`,
	p.`payroll_avg` `current_payroll`,
	p.`price_total_avg` `current_price`,
	p2.`year` `last_year`,
	p2.`payroll_avg` `last_payroll`,
	p2.`price_total_avg` `last_price`,
	ROUND((p.`payroll_avg` / p2.`payroll_avg` - 1) * 100, 2) `year_on_year_payroll_increase_%`,
	ROUND((p.`price_total_avg` / p2.`price_total_avg` - 1) * 100, 2) `year_on_year_price_increase_%`,
	ROUND(((p.`price_total_avg` / p2.`price_total_avg` - 1) * 100) - ((p.`payroll_avg` / p2.`payroll_avg` - 1) * 100), 2) `price_payroll_increase_diff`
FROM payroll_price p
JOIN payroll_price p2
	ON p.`year` = p2.`year` + 1;

-- OTÁZKA 5.

WITH payroll_price AS (
	SELECT
		`year`,
		`payroll_avg`,
		`payroll_unit`,
		ROUND(AVG(`price_avg`), 2) `price_total_avg`,
		`price_unit`,
		`GDP`,
		`GDP_unit`
	FROM t_radek_v_project_sql_primary_final t
	WHERE
		`year` BETWEEN 2006 AND 2018
		AND `industry_branch_name` = 'Všechna odvětví'
	GROUP BY `year`
)
SELECT
	p.`year` `current_year`,
	p.`payroll_avg` `current_payroll`,
	p.`price_total_avg` `current_price`,
	ROUND(p.`GDP`) `current_gdp`,
	p2.`year` `last_year`,
	p2.`payroll_avg` `last_payroll`,
	p2.`price_total_avg` `last_price`,
	ROUND(p2.`GDP`) `last_GDP`,
	ROUND((p.`payroll_avg` / p2.`payroll_avg` - 1) * 100, 2) `year_on_year_payroll_increase_%`,
	ROUND((p.`price_total_avg` / p2.`price_total_avg` - 1) * 100, 2) `year_on_year_price_increase_%`,
	ROUND((p.`GDP` / p2.`GDP` - 1) * 100, 2) `year_on_year_GDP_increase_%`
FROM payroll_price p
JOIN payroll_price p2
	ON p.`year` = p2.`year` + 1;