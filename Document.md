
# **Výzkumné otázky a odpovědi**

Nejprve byla vytvořena primární tabulka *t_radek_v_project_sql_primary_final*, která obsahuje veškerá potřebná data pro zodpovězení následujících otázek. Pomocí klauzule WITH byly vytvořeny 3 dočasné tabulky *payroll*, *price* a *economy*.

Tabulka *payroll* byla vytvořena spojením tabulek *czechia_payroll*, *czechia_payroll_industry_branch* a *czechia_payroll_unit*, abychom k údajům přiřadili názvy jednotlivých odvětví a jednotky. Údaje za čtyři čtvrtletí byly zprůměrovány a seskupeny dle odvětví a dle roku. Pomocí Case Expression bylo k hodnotám bez odvětví vyplněno 'Všechna odvětví'. Klauzulí WHERE byly odfiltrovány údaje z roku 2021, neboť obsahují neúplné údaje pouze z prvního a druhého čtvrtletí, dále nepotřebné údaje o počtech zaměstnanců a údaje označené kódem '100' 'fyzický, které nepřepočítávají hodnoty na plný pracovní úvazek. Byly tedy použity pouze hodnoty s kódem '200' 'přepočtený' na plný pracovní úvazek, protože mají lepší vypovídající hodnotu.

Tabulka *price* byla vytvořena spojením tabulek *czechia_price* a *czechia_price_category*, abychom k hodnotám přiřadili názvy kategorií potravin. Ze sloupce date_from byl funkcí YEAR vytažen pouze rok a týdenní údaje byly zprůměrovány a seskupeny podle jednotlivých kategorií a roků. Klauzulí WHERE byly odfiltrovány údaje vztažené k jednotlivým regionům a byly použity pouze údaje za celou ČR.

Z tabulky *economies* byly pouze klauzulí WHERE odfiltrovány hodnoty starší než z roku 2000, neboť k nim nemáme porovnání a údaje z ostatních zemí.

Nakonec byly spojeny tyto tři tabulky do jedné na základě roků a pouze v případech průměrných mezd za všechna odvětví. Údaje o mzdách z jednotlivých odvětví s údaji z ostatních tabulek nepotřebujeme porovnávat. Vybrány byly pouze potřebné sloupce a údaje seřazeny dle odvětví, roků a kategorií potravin.

1. **Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

    *Postup:*

    Data z tabulky *t_radek_v_project_sql_primary_final* byla seskupena podle odvětví a roků a zobrazeny sloupce s názvy odvětví, roky, hodnotami mezd a jednotkami (Kč). Nakonec došlo k vizuálnímu posouzení vývoje platů v jednotlivých odvětvích. 

    *Odpověď:*

    Mzdy v průběhu let rostou ve všech odvětvích.

1. **Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

    *Postup:*

    Pomocí klauzule WHERE byla z tabulky *t_radek_v_project_sql_primary_final* vybrána pouze data týkající se chleba a mléka a prvního a posledního porovnatelného roku 2006 a 2018. Zobrazeny byly pouze sloupce týkající se tohoto výpočtu. Vydělením průměrné mzdy cenou za jednotku potraviny bylo získáno, kolik si můžeme zakoupit jednotek za průměrnou mzdu v těchto letech. Údaje byly seřazeny podle názvu potraviny a podle roku.

    *Odpověď:*

    V prvním sledovaném roce 2006 jsme si mohli za průměrnou mzdu koupit 1 212 kg chleba nebo 1 353 l mléka a v posledním sledovaném roce 2018 1 322 kg chleba nebo 1 617 l mléka.

1. **Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

    *Postup:*

    Byly spojeny dvě tabulky *t_radek_v_project_sql_primary_final* na základě kategorií produktů a roků tak, abychom na jednom řádku měli zároveň současný a předchozí rok, aby mohlo dojít k meziročnímu porovnání. Došlo k výpočtu meziročního nárůstu cen a tyto hodnoty z jednotlivých let byly zprůměrovány (údaje byly seskupeny dle kategorií). Hodnoty byly seřazeny dle průměrného meziročního nárůstu. Výsledná potravina je na prvním místě tabulky.

    *Odpověď:*

    Nejpomaleji zdražuje potravina cukr krystalový, u kterého je průměrný meziroční nárůst -1,92 %. Z toho vyplývá, že tato potravina se za sledované období od roku 2006 do roku 2018 zlevnila.

1. **Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

    *Postup:*

    Nejprve byla pomocí klauzule WITH vytvořena dočasná tabulka *payroll_price*, kde byly zprůměrované ceny z jednotlivých kategorií do celkové průměrné ceny a seskupeno dle roků. Pomocí klauzule WHERE byly vybrány pouze porovnatelné roky mezi 2006 a 2018 a vybrány pouze všechna odvětví průměrných mezd. Následně byly spojeny dvě tyto tabulky na základě roků tak, abychom na jednom řádku měli zároveň současný a předchozí rok, aby mohlo dojít k meziročnímu porovnání. Z těchto údajů byl vypočítán meziroční nárůst mezd a meziroční nárůst cen potravin. Odečtením nárůstu mezd od nárůstu cen potravin byl zjištěn rozdíl.

    *Odpověď:*

    Rok, kdy byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (o více než 10 %) neexistuje. Největší nárůst cen potravin vzhledem k růstu mezd byl v roce 2013, kdy se mzdy snížily o 0,13 % a ceny potravin vzrostly o 5,1 % (rozdíl 5,23 %).

1. **Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněni v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

    *Postup:*

    Nejprve byla pomocí klauzule WITH vytvořena dočasná tabulka *payroll_price*, kde byly zprůměrované ceny z jednotlivých kategorií do celkové průměrné ceny a seskupeno dle roků. Pomocí klauzule WHERE byly vybrány pouze porovnatelné roky mezi 2006 a 2018 a vybrány pouze všechna odvětví průměrných mezd. Následně byly spojeny dvě tyto tabulky na základě roků tak, abychom na jednom řádku měli zároveň současný a předchozí rok, aby mohlo dojít k meziročnímu porovnání. Z těchto údajů byl vypočítán meziroční nárůst mezd, meziroční nárůst cen potravin a meziroční nárůst HDP. Nakonec došlo k vizuálnímu posouzení vývoje platů, cen a HDP v jednotlivých letech.

    *Odpověď:*

    Obecně lze konstatovat, že v případě výraznějšího růstu HDP více rostou i mzdy a ceny potravin, ale v některých letech existují výjimky.

Dále byla vytvořena sekundární tabulka *t_radek_v_project_SQL_secondary_final* spojením tabulek *countries* a *economies*. Tabulka *countries* byla použita z důvodu výběru pouze evropských zemí, neboť tabulka *economies* údaje o zařazení států do kontinentů neobsahuje. Klauzulí WHERE byly vybrány pouze požadované evropské země a období stejné jako v primární tabulce od roku 2000. Údaje jsou seřazeny dle země a následně dle roku. Zobrazeny jsou pouze požadované údaje z tabulky *economies* - země, rok, HDP, GINI koeficient a populace.