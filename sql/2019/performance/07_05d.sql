# standardSQL
# 07_05d: % fast FCP+FID per PSI by geo
with
    geos as (
        select
            *,
            'af' as geo_code,
            'Afghanistan' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_af.201907`
        union all
        select
            *,
            'ax' as geo_code,
            'Åland Islands' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_ax.201907`
        union all
        select
            *,
            'al' as geo_code,
            'Albania' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_al.201907`
        union all
        select
            *,
            'dz' as geo_code,
            'Algeria' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_dz.201907`
        union all
        select
            *,
            'as' as geo_code,
            'American Samoa' as geo,
            'Oceania' as region,
            'Polynesia' as subregion
        from `chrome-ux-report.country_as.201907`
        union all
        select
            *,
            'ad' as geo_code,
            'Andorra' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_ad.201907`
        union all
        select
            *,
            'ao' as geo_code,
            'Angola' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_ao.201907`
        union all
        select
            *,
            'ai' as geo_code,
            'Anguilla' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_ai.201907`
        union all
        select
            *,
            'ag' as geo_code,
            'Antigua and Barbuda' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_ag.201907`
        union all
        select
            *,
            'ar' as geo_code,
            'Argentina' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_ar.201907`
        union all
        select
            *,
            'am' as geo_code,
            'Armenia' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_am.201907`
        union all
        select
            *,
            'aw' as geo_code,
            'Aruba' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_aw.201907`
        union all
        select
            *,
            'au' as geo_code,
            'Australia' as geo,
            'Oceania' as region,
            'Australia and New Zealand' as subregion
        from `chrome-ux-report.country_au.201907`
        union all
        select
            *,
            'at' as geo_code,
            'Austria' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_at.201907`
        union all
        select
            *,
            'az' as geo_code,
            'Azerbaijan' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_az.201907`
        union all
        select
            *,
            'bs' as geo_code,
            'Bahamas' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_bs.201907`
        union all
        select
            *,
            'bh' as geo_code,
            'Bahrain' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_bh.201907`
        union all
        select
            *,
            'bd' as geo_code,
            'Bangladesh' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_bd.201907`
        union all
        select
            *,
            'bb' as geo_code,
            'Barbados' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_bb.201907`
        union all
        select
            *,
            'by' as geo_code,
            'Belarus' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_by.201907`
        union all
        select
            *,
            'be' as geo_code,
            'Belgium' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_be.201907`
        union all
        select
            *,
            'bz' as geo_code,
            'Belize' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_bz.201907`
        union all
        select
            *,
            'bj' as geo_code,
            'Benin' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_bj.201907`
        union all
        select
            *,
            'bm' as geo_code,
            'Bermuda' as geo,
            'Americas' as region,
            'Northern America' as subregion
        from `chrome-ux-report.country_bm.201907`
        union all
        select
            *,
            'bt' as geo_code,
            'Bhutan' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_bt.201907`
        union all
        select
            *,
            'bo' as geo_code,
            'Bolivia (Plurinational State of)' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_bo.201907`
        union all
        select
            *,
            'bq' as geo_code,
            'Bonaire, Sint Eustatius and Saba' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_bq.201907`
        union all
        select
            *,
            'ba' as geo_code,
            'Bosnia and Herzegovina' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_ba.201907`
        union all
        select
            *,
            'bw' as geo_code,
            'Botswana' as geo,
            'Africa' as region,
            'Southern Africa' as subregion
        from `chrome-ux-report.country_bw.201907`
        union all
        select
            *,
            'br' as geo_code,
            'Brazil' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_br.201907`
        union all
        select
            *,
            'io' as geo_code,
            'British Indian Ocean Territory' as geo,
            '' as region,
            'null' as subregion
        from `chrome-ux-report.country_io.201907`
        union all
        select
            *,
            'bn' as geo_code,
            'Brunei Darussalam' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_bn.201907`
        union all
        select
            *,
            'bg' as geo_code,
            'Kosovo' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_bg.201907`
        union all
        select
            *,
            'bf' as geo_code,
            'Burkina Faso' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_bf.201907`
        union all
        select
            *,
            'bi' as geo_code,
            'Burundi' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_bi.201907`
        union all
        select
            *,
            'kh' as geo_code,
            'Cambodia' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_kh.201907`
        union all
        select
            *,
            'cm' as geo_code,
            'Cameroon' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_cm.201907`
        union all
        select
            *,
            'ca' as geo_code,
            'Canada' as geo,
            'Americas' as region,
            'Northern America' as subregion
        from `chrome-ux-report.country_ca.201907`
        union all
        select
            *,
            'cv' as geo_code,
            'Cabo Verde' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_cv.201907`
        union all
        select
            *,
            'ky' as geo_code,
            'Cayman Islands' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_ky.201907`
        union all
        select
            *,
            'cf' as geo_code,
            'Central African Republic' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_cf.201907`
        union all
        select
            *,
            'td' as geo_code,
            'Chad' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_td.201907`
        union all
        select
            *,
            'cl' as geo_code,
            'Chile' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_cl.201907`
        union all
        select
            *,
            'cn' as geo_code,
            'China' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_cn.201907`
        union all
        select
            *,
            'cx' as geo_code,
            'Christmas Island' as geo,
            '' as region,
            'null' as subregion
        from `chrome-ux-report.country_cx.201907`
        union all
        select
            *,
            'co' as geo_code,
            'Colombia' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_co.201907`
        union all
        select
            *,
            'km' as geo_code,
            'Comoros' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_km.201907`
        union all
        select
            *,
            'cg' as geo_code,
            'Congo' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_cg.201907`
        union all
        select
            *,
            'cd' as geo_code,
            'Congo (Democratic Republic of the)' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_cd.201907`
        union all
        select
            *,
            'ck' as geo_code,
            'Cook Islands' as geo,
            'Oceania' as region,
            'Polynesia' as subregion
        from `chrome-ux-report.country_ck.201907`
        union all
        select
            *,
            'cr' as geo_code,
            'Costa Rica' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_cr.201907`
        union all
        select
            *,
            'ci' as geo_code,
            "Côte d'Ivoire" as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_ci.201907`
        union all
        select
            *,
            'hr' as geo_code,
            'Croatia' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_hr.201907`
        union all
        select
            *,
            'cu' as geo_code,
            'Cuba' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_cu.201907`
        union all
        select
            *,
            'cw' as geo_code,
            'Curaçao' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_cw.201907`
        union all
        select
            *,
            'cy' as geo_code,
            'Cyprus' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_cy.201907`
        union all
        select
            *,
            'cz' as geo_code,
            'Czech Republic' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_cz.201907`
        union all
        select
            *,
            'dk' as geo_code,
            'Denmark' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_dk.201907`
        union all
        select
            *,
            'dj' as geo_code,
            'Djibouti' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_dj.201907`
        union all
        select
            *,
            'dm' as geo_code,
            'Dominica' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_dm.201907`
        union all
        select
            *,
            'do' as geo_code,
            'Dominican Republic' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_do.201907`
        union all
        select
            *,
            'ec' as geo_code,
            'Ecuador' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_ec.201907`
        union all
        select
            *,
            'eg' as geo_code,
            'Egypt' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_eg.201907`
        union all
        select
            *,
            'sv' as geo_code,
            'El Salvador' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_sv.201907`
        union all
        select
            *,
            'gq' as geo_code,
            'Equatorial Guinea' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_gq.201907`
        union all
        select
            *,
            'er' as geo_code,
            'Eritrea' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_er.201907`
        union all
        select
            *,
            'ee' as geo_code,
            'Estonia' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_ee.201907`
        union all
        select
            *,
            'et' as geo_code,
            'Ethiopia' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_et.201907`
        union all
        select
            *,
            'fk' as geo_code,
            'Falkland Islands (Malvinas)' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_fk.201907`
        union all
        select
            *,
            'fo' as geo_code,
            'Faroe Islands' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_fo.201907`
        union all
        select
            *,
            'fj' as geo_code,
            'Fiji' as geo,
            'Oceania' as region,
            'Melanesia' as subregion
        from `chrome-ux-report.country_fj.201907`
        union all
        select
            *,
            'fi' as geo_code,
            'Finland' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_fi.201907`
        union all
        select
            *,
            'fr' as geo_code,
            'France' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_fr.201907`
        union all
        select
            *,
            'gf' as geo_code,
            'French Guiana' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_gf.201907`
        union all
        select
            *,
            'pf' as geo_code,
            'French Polynesia' as geo,
            'Oceania' as region,
            'Polynesia' as subregion
        from `chrome-ux-report.country_pf.201907`
        union all
        select
            *,
            'ga' as geo_code,
            'Gabon' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_ga.201907`
        union all
        select
            *,
            'gm' as geo_code,
            'Gambia' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_gm.201907`
        union all
        select
            *,
            'ge' as geo_code,
            'Georgia' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_ge.201907`
        union all
        select
            *,
            'de' as geo_code,
            'Germany' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_de.201907`
        union all
        select
            *,
            'gh' as geo_code,
            'Ghana' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_gh.201907`
        union all
        select
            *,
            'gi' as geo_code,
            'Gibraltar' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_gi.201907`
        union all
        select
            *,
            'gr' as geo_code,
            'Greece' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_gr.201907`
        union all
        select
            *,
            'gl' as geo_code,
            'Greenland' as geo,
            'Americas' as region,
            'Northern America' as subregion
        from `chrome-ux-report.country_gl.201907`
        union all
        select
            *,
            'gd' as geo_code,
            'Grenada' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_gd.201907`
        union all
        select
            *,
            'gp' as geo_code,
            'Guadeloupe' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_gp.201907`
        union all
        select
            *,
            'gu' as geo_code,
            'Guam' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_gu.201907`
        union all
        select
            *,
            'gt' as geo_code,
            'Guatemala' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_gt.201907`
        union all
        select
            *,
            'gg' as geo_code,
            'Guernsey' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_gg.201907`
        union all
        select
            *,
            'gn' as geo_code,
            'Guinea' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_gn.201907`
        union all
        select
            *,
            'gw' as geo_code,
            'Guinea-Bissau' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_gw.201907`
        union all
        select
            *,
            'gy' as geo_code,
            'Guyana' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_gy.201907`
        union all
        select
            *,
            'ht' as geo_code,
            'Haiti' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_ht.201907`
        union all
        select
            *,
            'hn' as geo_code,
            'Honduras' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_hn.201907`
        union all
        select
            *,
            'hk' as geo_code,
            'Hong Kong' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_hk.201907`
        union all
        select
            *,
            'hu' as geo_code,
            'Hungary' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_hu.201907`
        union all
        select
            *,
            'is' as geo_code,
            'Iceland' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_is.201907`
        union all
        select
            *,
            'in' as geo_code,
            'India' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_in.201907`
        union all
        select
            *,
            'id' as geo_code,
            'Indonesia' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_id.201907`
        union all
        select
            *,
            'ir' as geo_code,
            'Iran (Islamic Republic of)' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_ir.201907`
        union all
        select
            *,
            'iq' as geo_code,
            'Iraq' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_iq.201907`
        union all
        select
            *,
            'ie' as geo_code,
            'Ireland' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_ie.201907`
        union all
        select
            *,
            'im' as geo_code,
            'Isle of Man' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_im.201907`
        union all
        select
            *,
            'il' as geo_code,
            'Israel' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_il.201907`
        union all
        select
            *,
            'it' as geo_code,
            'Italy' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_it.201907`
        union all
        select
            *,
            'jm' as geo_code,
            'Jamaica' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_jm.201907`
        union all
        select
            *,
            'jp' as geo_code,
            'Japan' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_jp.201907`
        union all
        select
            *,
            'je' as geo_code,
            'Jersey' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_je.201907`
        union all
        select
            *,
            'jo' as geo_code,
            'Jordan' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_jo.201907`
        union all
        select
            *,
            'kz' as geo_code,
            'Kazakhstan' as geo,
            'Asia' as region,
            'Central Asia' as subregion
        from `chrome-ux-report.country_kz.201907`
        union all
        select
            *,
            'ke' as geo_code,
            'Kenya' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_ke.201907`
        union all
        select
            *,
            'ki' as geo_code,
            'Kiribati' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_ki.201907`
        union all
        select
            *,
            'kp' as geo_code,
            "Korea (Democratic People's Republic of)" as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_kp.201907`
        union all
        select
            *,
            'kr' as geo_code,
            'Korea (Republic of)' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_kr.201907`
        union all
        select
            *,
            'kw' as geo_code,
            'Kuwait' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_kw.201907`
        union all
        select
            *,
            'kg' as geo_code,
            'Kyrgyzstan' as geo,
            'Asia' as region,
            'Central Asia' as subregion
        from `chrome-ux-report.country_kg.201907`
        union all
        select
            *,
            'la' as geo_code,
            "Lao People's Democratic Republic" as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_la.201907`
        union all
        select
            *,
            'lv' as geo_code,
            'Latvia' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_lv.201907`
        union all
        select
            *,
            'lb' as geo_code,
            'Lebanon' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_lb.201907`
        union all
        select
            *,
            'ls' as geo_code,
            'Lesotho' as geo,
            'Africa' as region,
            'Southern Africa' as subregion
        from `chrome-ux-report.country_ls.201907`
        union all
        select
            *,
            'lr' as geo_code,
            'Liberia' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_lr.201907`
        union all
        select
            *,
            'ly' as geo_code,
            'Libya' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_ly.201907`
        union all
        select
            *,
            'li' as geo_code,
            'Liechtenstein' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_li.201907`
        union all
        select
            *,
            'lt' as geo_code,
            'Lithuania' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_lt.201907`
        union all
        select
            *,
            'lu' as geo_code,
            'Luxembourg' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_lu.201907`
        union all
        select
            *,
            'mo' as geo_code,
            'Macao' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_mo.201907`
        union all
        select
            *,
            'mk' as geo_code,
            'Macedonia (the former Yugoslav Republic of)' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_mk.201907`
        union all
        select
            *,
            'mg' as geo_code,
            'Madagascar' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_mg.201907`
        union all
        select
            *,
            'mw' as geo_code,
            'Malawi' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_mw.201907`
        union all
        select
            *,
            'my' as geo_code,
            'Malaysia' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_my.201907`
        union all
        select
            *,
            'mv' as geo_code,
            'Maldives' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_mv.201907`
        union all
        select
            *,
            'ml' as geo_code,
            'Mali' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_ml.201907`
        union all
        select
            *,
            'mt' as geo_code,
            'Malta' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_mt.201907`
        union all
        select
            *,
            'mh' as geo_code,
            'Marshall Islands' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_mh.201907`
        union all
        select
            *,
            'mq' as geo_code,
            'Martinique' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_mq.201907`
        union all
        select
            *,
            'mr' as geo_code,
            'Mauritania' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_mr.201907`
        union all
        select
            *,
            'mu' as geo_code,
            'Mauritius' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_mu.201907`
        union all
        select
            *,
            'yt' as geo_code,
            'Mayotte' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_yt.201907`
        union all
        select
            *,
            'mx' as geo_code,
            'Mexico' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_mx.201907`
        union all
        select
            *,
            'fm' as geo_code,
            'Micronesia (Federated States of)' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_fm.201907`
        union all
        select
            *,
            'md' as geo_code,
            'Moldova (Republic of)' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_md.201907`
        union all
        select
            *,
            'mc' as geo_code,
            'Monaco' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_mc.201907`
        union all
        select
            *,
            'mn' as geo_code,
            'Mongolia' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_mn.201907`
        union all
        select
            *,
            'me' as geo_code,
            'Montenegro' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_me.201907`
        union all
        select
            *,
            'ms' as geo_code,
            'Montserrat' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_ms.201907`
        union all
        select
            *,
            'ma' as geo_code,
            'Morocco' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_ma.201907`
        union all
        select
            *,
            'mz' as geo_code,
            'Mozambique' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_mz.201907`
        union all
        select
            *,
            'mm' as geo_code,
            'Myanmar' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_mm.201907`
        union all
        select
            *,
            'na' as geo_code,
            'Namibia' as geo,
            'Africa' as region,
            'Southern Africa' as subregion
        from `chrome-ux-report.country_na.201907`
        union all
        select
            *,
            'nr' as geo_code,
            'Nauru' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_nr.201907`
        union all
        select
            *,
            'np' as geo_code,
            'Nepal' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_np.201907`
        union all
        select
            *,
            'nl' as geo_code,
            'Netherlands' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_nl.201907`
        union all
        select
            *,
            'nc' as geo_code,
            'New Caledonia' as geo,
            'Oceania' as region,
            'Melanesia' as subregion
        from `chrome-ux-report.country_nc.201907`
        union all
        select
            *,
            'nz' as geo_code,
            'New Zealand' as geo,
            'Oceania' as region,
            'Australia and New Zealand' as subregion
        from `chrome-ux-report.country_nz.201907`
        union all
        select
            *,
            'ni' as geo_code,
            'Nicaragua' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_ni.201907`
        union all
        select
            *,
            'ne' as geo_code,
            'Niger' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_ne.201907`
        union all
        select
            *,
            'ng' as geo_code,
            'Nigeria' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_ng.201907`
        union all
        select
            *,
            'nf' as geo_code,
            'Norfolk Island' as geo,
            'Oceania' as region,
            'Australia and New Zealand' as subregion
        from `chrome-ux-report.country_nf.201907`
        union all
        select
            *,
            'mp' as geo_code,
            'Northern Mariana Islands' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_mp.201907`
        union all
        select
            *,
            'no' as geo_code,
            'Norway' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_no.201907`
        union all
        select
            *,
            'om' as geo_code,
            'Oman' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_om.201907`
        union all
        select
            *,
            'pk' as geo_code,
            'Pakistan' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_pk.201907`
        union all
        select
            *,
            'pw' as geo_code,
            'Palau' as geo,
            'Oceania' as region,
            'Micronesia' as subregion
        from `chrome-ux-report.country_pw.201907`
        union all
        select
            *,
            'ps' as geo_code,
            'Palestine, State of' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_ps.201907`
        union all
        select
            *,
            'pa' as geo_code,
            'Panama' as geo,
            'Americas' as region,
            'Central America' as subregion
        from `chrome-ux-report.country_pa.201907`
        union all
        select
            *,
            'pg' as geo_code,
            'Papua New Guinea' as geo,
            'Oceania' as region,
            'Melanesia' as subregion
        from `chrome-ux-report.country_pg.201907`
        union all
        select
            *,
            'py' as geo_code,
            'Paraguay' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_py.201907`
        union all
        select
            *,
            'pe' as geo_code,
            'Peru' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_pe.201907`
        union all
        select
            *,
            'ph' as geo_code,
            'Philippines' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_ph.201907`
        union all
        select
            *,
            'pl' as geo_code,
            'Poland' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_pl.201907`
        union all
        select
            *,
            'pt' as geo_code,
            'Portugal' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_pt.201907`
        union all
        select
            *,
            'pr' as geo_code,
            'Puerto Rico' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_pr.201907`
        union all
        select
            *,
            'qa' as geo_code,
            'Qatar' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_qa.201907`
        union all
        select
            *,
            're' as geo_code,
            'Réunion' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_re.201907`
        union all
        select
            *,
            'ro' as geo_code,
            'Romania' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_ro.201907`
        union all
        select
            *,
            'ru' as geo_code,
            'Russian Federation' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_ru.201907`
        union all
        select
            *,
            'rw' as geo_code,
            'Rwanda' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_rw.201907`
        union all
        select
            *,
            'bl' as geo_code,
            'Saint Barthélemy' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_bl.201907`
        union all
        select
            *,
            'sh' as geo_code,
            'Saint Helena, Ascension and Tristan da Cunha' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_sh.201907`
        union all
        select
            *,
            'kn' as geo_code,
            'Saint Kitts and Nevis' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_kn.201907`
        union all
        select
            *,
            'lc' as geo_code,
            'Saint Lucia' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_lc.201907`
        union all
        select
            *,
            'mf' as geo_code,
            'Saint Martin (French part)' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_mf.201907`
        union all
        select
            *,
            'pm' as geo_code,
            'Saint Pierre and Miquelon' as geo,
            'Americas' as region,
            'Northern America' as subregion
        from `chrome-ux-report.country_pm.201907`
        union all
        select
            *,
            'vc' as geo_code,
            'Saint Vincent and the Grenadines' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_vc.201907`
        union all
        select
            *,
            'ws' as geo_code,
            'Samoa' as geo,
            'Oceania' as region,
            'Polynesia' as subregion
        from `chrome-ux-report.country_ws.201907`
        union all
        select
            *,
            'sm' as geo_code,
            'San Marino' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_sm.201907`
        union all
        select
            *,
            'st' as geo_code,
            'Sao Tome and Principe' as geo,
            'Africa' as region,
            'Middle Africa' as subregion
        from `chrome-ux-report.country_st.201907`
        union all
        select
            *,
            'sa' as geo_code,
            'Saudi Arabia' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_sa.201907`
        union all
        select
            *,
            'sn' as geo_code,
            'Senegal' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_sn.201907`
        union all
        select
            *,
            'rs' as geo_code,
            'Serbia' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_rs.201907`
        union all
        select
            *,
            'sc' as geo_code,
            'Seychelles' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_sc.201907`
        union all
        select
            *,
            'sl' as geo_code,
            'Sierra Leone' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_sl.201907`
        union all
        select
            *,
            'sg' as geo_code,
            'Singapore' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_sg.201907`
        union all
        select
            *,
            'sx' as geo_code,
            'Sint Maarten (Dutch part)' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_sx.201907`
        union all
        select
            *,
            'sk' as geo_code,
            'Slovakia' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_sk.201907`
        union all
        select
            *,
            'si' as geo_code,
            'Slovenia' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_si.201907`
        union all
        select
            *,
            'sb' as geo_code,
            'Solomon Islands' as geo,
            'Oceania' as region,
            'Melanesia' as subregion
        from `chrome-ux-report.country_sb.201907`
        union all
        select
            *,
            'so' as geo_code,
            'Somalia' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_so.201907`
        union all
        select
            *,
            'za' as geo_code,
            'South Africa' as geo,
            'Africa' as region,
            'Southern Africa' as subregion
        from `chrome-ux-report.country_za.201907`
        union all
        select
            *,
            'ss' as geo_code,
            'South Sudan' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_ss.201907`
        union all
        select
            *,
            'es' as geo_code,
            'Spain' as geo,
            'Europe' as region,
            'Southern Europe' as subregion
        from `chrome-ux-report.country_es.201907`
        union all
        select
            *,
            'lk' as geo_code,
            'Sri Lanka' as geo,
            'Asia' as region,
            'Southern Asia' as subregion
        from `chrome-ux-report.country_lk.201907`
        union all
        select
            *,
            'sd' as geo_code,
            'Sudan' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_sd.201907`
        union all
        select
            *,
            'sr' as geo_code,
            'Suriname' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_sr.201907`
        union all
        select
            *,
            'sj' as geo_code,
            'Svalbard and Jan Mayen' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_sj.201907`
        union all
        select
            *,
            'sz' as geo_code,
            'Swaziland' as geo,
            'Africa' as region,
            'Southern Africa' as subregion
        from `chrome-ux-report.country_sz.201907`
        union all
        select
            *,
            'se' as geo_code,
            'Sweden' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_se.201907`
        union all
        select
            *,
            'ch' as geo_code,
            'Switzerland' as geo,
            'Europe' as region,
            'Western Europe' as subregion
        from `chrome-ux-report.country_ch.201907`
        union all
        select
            *,
            'sy' as geo_code,
            'Syrian Arab Republic' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_sy.201907`
        union all
        select
            *,
            'tw' as geo_code,
            'Taiwan, Province of China' as geo,
            'Asia' as region,
            'Eastern Asia' as subregion
        from `chrome-ux-report.country_tw.201907`
        union all
        select
            *,
            'tj' as geo_code,
            'Tajikistan' as geo,
            'Asia' as region,
            'Central Asia' as subregion
        from `chrome-ux-report.country_tj.201907`
        union all
        select
            *,
            'tz' as geo_code,
            'Tanzania, United Republic of' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_tz.201907`
        union all
        select
            *,
            'th' as geo_code,
            'Thailand' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_th.201907`
        union all
        select
            *,
            'tl' as geo_code,
            'Timor-Leste' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_tl.201907`
        union all
        select
            *,
            'tg' as geo_code,
            'Togo' as geo,
            'Africa' as region,
            'Western Africa' as subregion
        from `chrome-ux-report.country_tg.201907`
        union all
        select
            *,
            'to' as geo_code,
            'Tonga' as geo,
            'Oceania' as region,
            'Polynesia' as subregion
        from `chrome-ux-report.country_to.201907`
        union all
        select
            *,
            'tt' as geo_code,
            'Trinidad and Tobago' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_tt.201907`
        union all
        select
            *,
            'tn' as geo_code,
            'Tunisia' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_tn.201907`
        union all
        select
            *,
            'tr' as geo_code,
            'Turkey' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_tr.201907`
        union all
        select
            *,
            'tm' as geo_code,
            'Turkmenistan' as geo,
            'Asia' as region,
            'Central Asia' as subregion
        from `chrome-ux-report.country_tm.201907`
        union all
        select
            *,
            'tc' as geo_code,
            'Turks and Caicos Islands' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_tc.201907`
        union all
        select
            *,
            'tv' as geo_code,
            'Tuvalu' as geo,
            'Oceania' as region,
            'Polynesia' as subregion
        from `chrome-ux-report.country_tv.201907`
        union all
        select
            *,
            'ug' as geo_code,
            'Uganda' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_ug.201907`
        union all
        select
            *,
            'ua' as geo_code,
            'Ukraine' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_ua.201907`
        union all
        select
            *,
            'ae' as geo_code,
            'United Arab Emirates' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_ae.201907`
        union all
        select
            *,
            'gb' as geo_code,
            'United Kingdom of Great Britain and Northern Ireland' as geo,
            'Europe' as region,
            'Northern Europe' as subregion
        from `chrome-ux-report.country_gb.201907`
        union all
        select
            *,
            'us' as geo_code,
            'United States of America' as geo,
            'Americas' as region,
            'Northern America' as subregion
        from `chrome-ux-report.country_us.201907`
        union all
        select
            *,
            'uy' as geo_code,
            'Uruguay' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_uy.201907`
        union all
        select
            *,
            'uz' as geo_code,
            'Uzbekistan' as geo,
            'Asia' as region,
            'Central Asia' as subregion
        from `chrome-ux-report.country_uz.201907`
        union all
        select
            *,
            'vu' as geo_code,
            'Vanuatu' as geo,
            'Oceania' as region,
            'Melanesia' as subregion
        from `chrome-ux-report.country_vu.201907`
        union all
        select
            *,
            've' as geo_code,
            'Venezuela (Bolivarian Republic of)' as geo,
            'Americas' as region,
            'South America' as subregion
        from `chrome-ux-report.country_ve.201907`
        union all
        select
            *,
            'vn' as geo_code,
            'Viet Nam' as geo,
            'Asia' as region,
            'South-Eastern Asia' as subregion
        from `chrome-ux-report.country_vn.201907`
        union all
        select
            *,
            'vg' as geo_code,
            'Virgin Islands (British)' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_vg.201907`
        union all
        select
            *,
            'vi' as geo_code,
            'Virgin Islands (U.S.)' as geo,
            'Americas' as region,
            'Caribbean' as subregion
        from `chrome-ux-report.country_vi.201907`
        union all
        select
            *,
            'eh' as geo_code,
            'Western Sahara' as geo,
            'Africa' as region,
            'Northern Africa' as subregion
        from `chrome-ux-report.country_eh.201907`
        union all
        select
            *,
            'ye' as geo_code,
            'Yemen' as geo,
            'Asia' as region,
            'Western Asia' as subregion
        from `chrome-ux-report.country_ye.201907`
        union all
        select
            *,
            'zm' as geo_code,
            'Zambia' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_zm.201907`
        union all
        select
            *,
            'zw' as geo_code,
            'Zimbabwe' as geo,
            'Africa' as region,
            'Eastern Africa' as subregion
        from `chrome-ux-report.country_zw.201907`
        union all
        select
            *,
            'xk' as geo_code,
            'Kosovo' as geo,
            'Europe' as region,
            'Eastern Europe' as subregion
        from `chrome-ux-report.country_xk.201907`
    )

select
    geo,
    count(0) as websites,
    round(countif(fast_fcp >= .9 and fast_fid >= .95) * 100 / count(0), 2) as pct_fast,
    round(
        countif(
            not (slow_fcp >= .1 or slow_fid >= 0.05)
            and not (fast_fcp >= .9 and fast_fid >= .95)
        )
        * 100 / count(
            0
        ),
        2
    ) as pct_avg,
    round(countif(slow_fcp >= .1 or slow_fid >= 0.05) * 100 / count(0), 2) as pct_slow
from
    (
        select
            geo,
            round(
                safe_divide(
                    sum(if(fcp.start < 1000, fcp.density, 0)), sum(fcp.density)
                ),
                4
            ) as fast_fcp,
            round(
                safe_divide(
                    sum(if(fcp.start >= 1000 and fcp.start < 2500, fcp.density, 0)),
                    sum(fcp.density)
                ),
                4
            ) as avg_fcp,
            round(
                safe_divide(
                    sum(if(fcp.start >= 2500, fcp.density, 0)), sum(fcp.density)
                ),
                4
            ) as slow_fcp,
            round(
                safe_divide(sum(if(fid.start < 50, fid.density, 0)), sum(fid.density)),
                4
            ) as fast_fid,
            round(
                safe_divide(
                    sum(if(fid.start >= 50 and fid.start < 250, fid.density, 0)),
                    sum(fid.density)
                ),
                4
            ) as avg_fid,
            round(
                safe_divide(
                    sum(if(fid.start >= 250, fid.density, 0)), sum(fid.density)
                ),
                4
            ) as slow_fid
        from
            geos,
            unnest(first_contentful_paint.histogram.fid) as fcp,
            unnest(experimental.first_input_delay.histogram.fid) as fid
        group by origin, geo
    )
where fast_fid + avg_fid + slow_fid > 0
group by geo
order by websites * pct_fast desc
