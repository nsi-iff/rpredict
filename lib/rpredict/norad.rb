module RPredict
  module Norad

    # Flow control flag definitions
    SGP4_INITIALIZED_FLAG  =  0x000002
    SDP4_INITIALIZED_FLAG  =  0x000004
    SIMPLE_FLAG            =  0x000020

    LUNAR_TERMS_DONE_FLAG  =  0x000080
    DO_LOOP_FLAG           =  0x000200
    RESONANCE_FLAG         =  0x000400
    SYNCHRONOUS_FLAG       =  0x000800
    EPOCH_RESTART_FLAG     =  0x001000


    SGP_INITIALIZED_FLAG   =  0x000001

    SGP8_INITIALIZED_FLAG  =  0x000008
    SDP8_INITIALIZED_FLAG  =  0x000010


    NEW_EPHEMERIS_FLAG     =  0x000100
    DO_LOOP_FLAG           =  0x000200


    # Flow control flag definitions
    ALL_FLAGS              =  -1
    VISIBLE_FLAG           =  0x002000
    SAT_ECLIPSED_FLAG      =  0x004000
    DEEP_SPACE_EPHEM_FLAG  =  0x000040


    # Constants used by SGP4/SDP4 code

    TWOPI    = 2.0*Math::PI
    PI2      = Math::PI/2
    E6A      = 1.0E-6
    XMNPDA   = 1.44E3
    AE       = 1.0
    TOTHRD   = 6.6666666666666666E-1 # 2/3
    XJ3      = -2.53881E-6      # J3 Harmonic */

    XKE      = 7.43669161E-2
    CK2      = 5.413079E-4
    CK4      = 6.209887E-7
    XKMPER   = 6.378137E3
    F__      = 3.352779E-3
    S__      = 1.012229
    QOMS2T   = 1.880279E-09
    OMEGA_E  = 1.00273790934

    ZNS      = 1.19459E-5
    C1SS     = 2.9864797E-6
    ZES      = 1.675E-2

    ZCOSIS   = 9.1744867E-1
    ZSINIS   = 3.9785416E-1
    ZSINGS   = -9.8088458E-1
    ZCOSGS   = 1.945905E-1
    ZCOSHS   = 1
    ZSINHS   = 0

    Q22      = 1.7891679E-6
    Q31      = 2.1460748E-6
    Q33      = 2.2123015E-7
    G22      = 5.7686396
    G32      = 9.5240898E-1
    G44      = 1.8014998
    G52      = 1.0508330
    G54      = 4.4108898

    ROOT22   = 1.7891679E-6
    ROOT32   = 3.7393792E-7
    ROOT44   = 7.3636953E-9
    ROOT52   = 1.1428639E-7
    ROOT54   = 2.1765803E-9
    SECDAY   = 8.6400E4

    THDT     = 4.3752691E-3

    MFACTOR  = 7.292115E-5
    SR__     = 6.96000E5      # Solar radius - kilometers (IAU 76)*/
    AU       = 1.49597870E8

    # Entry points of Deep()
    # FIXME: Change to enu
    DPINIT   = 1 # Deep-space initialization code
    DPSEC    = 2 # Deep-space secular code
    DPPER    = 3 # Deep-space periodic code



    #Global variables for sharing data among functions...

    flags    =  0
    aostime  =  0.0

    TXX =  (TWOPI/XMNPDA/XMNPDA)




  end
end
