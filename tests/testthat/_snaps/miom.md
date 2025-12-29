# miom functionality

    Code
      my_miom$multiregional_multipliers
    Output
        destination_country destination_sector destination_label
      1                  R1                 S1             R1_S1
      2                  R1                 S2             R1_S2
      3                  R2                 S1             R2_S1
      4                  R2                 S2             R2_S2
        intra_regional_multiplier spillover_multiplier total_multiplier
      1                  1.220128           0.04777924         1.267907
      2                  1.203969           0.06268995         1.266659
      3                  1.291260           0.09283816         1.384098
      4                  1.253676           0.04347194         1.297148
        multiplier_to_R1 multiplier_to_R2
      1       1.22012815       0.04777924
      2       1.20396888       0.06268995
      3       0.09283816       1.29126007
      4       0.04347194       1.25367608

---

    Code
      summary
    Output
        country multiplier_simple_mean multiplier_simple_sum multiplier_simple_sd
      1      R1               1.267283              2.534566         0.0008828619
      2      R2               1.340623              2.681246         0.0614830797
        multiplier_direct_mean multiplier_direct_sum multiplier_direct_sd
      1              0.2091667             0.4183333          0.001178511
      2              0.2573864             0.5147727          0.042587113
        multiplier_indirect_mean multiplier_indirect_sum multiplier_indirect_sd
      1                 1.058116                2.116233           0.0002956494
      2                 1.083237                2.166474           0.0188959668

---

    Code
      head(my_miom$multiplier_output)
    Output
        sector multiplier_simple multiplier_direct multiplier_indirect country
      1  R1_S1          1.267907         0.2100000            1.057907      R1
      2  R1_S2          1.266659         0.2083333            1.058325      R1
      3  R2_S1          1.384098         0.2875000            1.096598      R2
      4  R2_S2          1.297148         0.2272727            1.069875      R2
        sector_name
      1          S1
      2          S2
      3          S1
      4          S2

---

    Code
      my_miom$key_sectors
    Output
        sector power_dispersion sensitivity_dispersion power_dispersion_cv
      1  R1_S1        0.9723566              0.9374830            1.727805
      2  R1_S2        0.9713991              1.0260900            1.740098
      3  R2_S1        1.0614632              0.9786355            1.625827
      4  R2_S2        0.9947812              1.0577915            1.767213
        sensitivity_dispersion_cv             key_sectors country sector_name
      1                  1.793273          Non-Key Sector      R1          S1
      2                  1.645140  Strong Forward Linkage      R1          S2
      3                  1.765255 Strong Backward Linkage      R2          S1
      4                  1.660259  Strong Forward Linkage      R2          S2

---

    Code
      interdependence
    Output
        country self_reliance total_spillover_out total_spillover_in
      1      R1      1.212049          0.05523460         0.03407752
      2      R2      1.272468          0.06815505         0.02761730
        interdependence_index
      1            0.04557127
      2            0.05356130

---

    Code
      spillover_matrix
    Output
                 R1_S1      R1_S2      R2_S1      R2_S2
      R1_S1 0.00000000 0.00000000 0.03655421 0.01490746
      R1_S2 0.00000000 0.00000000 0.05628395 0.02856448
      R2_S1 0.01650383 0.02480224 0.00000000 0.00000000
      R2_S2 0.03127541 0.03788771 0.00000000 0.00000000

---

    Code
      net_spillover
    Output
                  R1         R2
      R1  0.00000000 0.02584091
      R2 -0.02584091 0.00000000

# miom integration functionality (real data)

    Code
      head(multipliers)
    Output
        destination_country                         destination_sector
      1                 AUS Agriculture, Hunting, Forestry and Fishing
      2                 AUS                       Mining and Quarrying
      3                 AUS                Food, Beverages and Tobacco
      4                 AUS             Textiles, leather and footwear
      5                 AUS       Pulp, paper, printing and publishing
      6                 AUS   Coke, refined petroleum and nuclear fuel
                                     destination_label intra_regional_multiplier
      1 AUS_Agriculture, Hunting, Forestry and Fishing                  1.817935
      2                       AUS_Mining and Quarrying                  1.693470
      3                AUS_Food, Beverages and Tobacco                  2.328641
      4             AUS_Textiles, leather and footwear                  2.062561
      5       AUS_Pulp, paper, printing and publishing                  2.027522
      6   AUS_Coke, refined petroleum and nuclear fuel                  2.292220
        spillover_multiplier total_multiplier multiplier_to_AUS multiplier_to_AUT
      1            0.2330955         2.051030          1.817935       0.001180087
      2            0.2126723         1.906142          1.693470       0.001129900
      3            0.2703186         2.598959          2.328641       0.001521005
      4            0.4555712         2.518132          2.062561       0.002526690
      5            0.3071864         2.334709          2.027522       0.002207287
      6            0.4805511         2.772771          2.292220       0.001809291
        multiplier_to_BEL multiplier_to_BRA multiplier_to_CAN multiplier_to_CHN
      1       0.003069871       0.001881841       0.004960912        0.01256687
      2       0.001974305       0.001227409       0.004432738        0.01058790
      3       0.003039900       0.002738322       0.005781616        0.01411311
      4       0.005555159       0.002916087       0.007131797        0.04251308
      5       0.003898980       0.002359719       0.007519892        0.01495853
      6       0.003556225       0.002117934       0.009537972        0.01882561
        multiplier_to_DEU multiplier_to_DNK multiplier_to_ESP multiplier_to_FIN
      1       0.013153683       0.001240671       0.002570894       0.001650781
      2       0.009925436       0.001002680       0.002231287       0.001589274
      3       0.014002195       0.001520054       0.003131240       0.003048380
      4       0.024269801       0.001964144       0.005069231       0.002747246
      5       0.019018955       0.001489067       0.003449367       0.008638684
      6       0.015294878       0.001759500       0.003876029       0.002047715
        multiplier_to_FRA multiplier_to_GBR multiplier_to_GRC multiplier_to_HKG
      1       0.007907709        0.01389229      0.0003027832       0.002851073
      2       0.005890179        0.01076223      0.0002592713       0.002890379
      3       0.008479433        0.01488730      0.0004565630       0.003681249
      4       0.014287449        0.02609042      0.0006459805       0.008741321
      5       0.010778682        0.01695062      0.0003838097       0.004210729
      6       0.009610284        0.01557436      0.0005809146       0.005544179
        multiplier_to_IND multiplier_to_IRL multiplier_to_ITA multiplier_to_JPN
      1       0.002405722       0.002193677       0.008217364        0.02214613
      2       0.001661708       0.001302873       0.006385196        0.01961257
      3       0.002941784       0.001813983       0.009285896        0.02575615
      4       0.010959368       0.002172372       0.021430437        0.03084705
      5       0.002836771       0.002341308       0.011867376        0.02649560
      6       0.003199694       0.002228562       0.010105838        0.02632205
        multiplier_to_KOR multiplier_to_MEX multiplier_to_NDL multiplier_to_PRT
      1       0.008296615      0.0012797838       0.004401521      0.0004749213
      2       0.007770448      0.0009557577       0.002595696      0.0004714334
      3       0.010736740      0.0012678675       0.005197586      0.0005721080
      4       0.035419632      0.0019989136       0.006374384      0.0011868518
      5       0.011621187      0.0014024562       0.005070974      0.0006307974
      6       0.010680129      0.0015399717       0.004856318      0.0006728823
        multiplier_to_SWE multiplier_to_TWN multiplier_to_USA multiplier_to_ROW
      1       0.002879795       0.006054460        0.05646532        0.05105068
      2       0.002868007       0.005672427        0.04086263        0.06861060
      3       0.003805267       0.007635361        0.05804229        0.06686325
      4       0.003952448       0.021839430        0.07934894        0.09558301
      5       0.005660992       0.007388820        0.06924758        0.06675818
      6       0.003703847       0.007209139        0.06484646        0.25505133

