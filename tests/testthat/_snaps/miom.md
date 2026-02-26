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

