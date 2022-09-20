import numpy as np
import matplotlib.pyplot as plt
import math

vec1 = np.array([[1, 2, 3], [4, 5, 6]])
print(np.mean(vec1))
print(np.mean(vec1, axis=-1))


exit(0)

X = [
    [0.0, 0.0],
    [0.0021090432314910747, 0.009775067091723806],
    [0.01682941969615793, 0.010806046117362796],
    [0.029983371855640952, 0.0009987052449836763],
    [0.018293537887158217, 0.03557170886492673],
    [0.049888806737120844, -0.003332710960495363],
    [0.05875336680343772, -0.012167246576802147],
    [0.06929837763873262, -0.009886094104326792],
    [0.07734612453569442, 0.020434701351104936],
    [0.08835129506695744, -0.017147847094939453],
    [0.09861370916460617, -0.01659326263272134],
    [0.10669382496219557, 0.02676616735613023],
    [0.10358512399786486, -0.06058153255198285],
    [0.10510453249654672, -0.0765051452431949],
    [0.12502788240678508, -0.06299229017010825],
    [0.06747686703699404, -0.13396593751723543],
    [0.08756235998807445, -0.13391352849252708],
    [0.1668857795709196, -0.03239037784599675],
    [0.12158337249920713, -0.13273086879742427],
    [0.015011941182004043, -0.1894060231934245],
    [0.11360310958222605, -0.16460356464320192],
    [-0.030531940895447435, -0.20776862271564714],
    [0.1180872601602638, -0.18562165549267737],
    [0.01817234985189943, -0.2292809754446718],
    [0.12372032923715136, -0.20565330080854746],
    [0.004147973057336866, -0.2499655862704217],
    [0.0840279718199185, -0.24604735306812592],
    [-0.0022699567891302473, -0.2699904577872624],
    [-0.182175038378247, -0.2126317365585022],
    [-0.2046523215938584, -0.2054687987657591],
    [-0.13943963640948295, -0.2656249005609061],
    [-0.10145203687201725, -0.29292914538249504],
    [-0.25232808141638285, -0.19680076048818343],
    [-0.07632695809266767, -0.3210517021732173],
    [-0.3355269118911007, -0.05496991356025283],
    [-0.34779185127171275, -0.039253384427268605],
    [-0.2202688407393794, -0.2847483762891898],
    [-0.36973833192088995, 0.013912796568551988],
    [-0.3693231663726919, 0.08944494832269215],
    [-0.2983163443145654, -0.25121178060511773],
    [-0.32731084442576486, -0.2299295786133069],
    [-0.3931847664147285, -0.11621419646237531],
    [-0.3245610847735143, 0.26657100789590726],
    [-0.310904944487702, 0.29704901193759103],
    [-0.4276373505368012, 0.10356783489995933],
    [-0.4051794631938031, 0.19577947442462332],
    [-0.2034678057460449, 0.41255405951813146],
    [-0.38453024499093275, 0.27025264233160323],
    [-0.12255668572918958, 0.4640903562702816],
    [-0.1369135941174721, 0.47048344045868007],
    [-0.30584112499961535, 0.39555177443537004],
    [-0.4535133907282313, 0.23329295838105107],
    [-0.09472450222148854, 0.5112995879901444],
    [-0.31892534083484014, 0.42330441407264036],
    [-0.0246614850956269, 0.5394365682384523],
    [0.17786704250846508, 0.5204453047048192],
    [0.16779807888473186, 0.534269412115829],
    [0.11565080814087429, 0.5581441485641169],
    [0.3643908001382336, 0.45124200244948187],
    [0.1977664378098525, 0.555867282789698],
    [-0.10191464256184789, 0.5912811561613402],
    [0.25391114813806215, 0.5546432446638213],
    [0.3834613994610764, 0.4871933447034691],
    [0.17368908828337387, 0.6055840987107329],
    [0.6082152325502793, 0.19918391223643067],
    [0.2997612820565208, 0.576752263783881],
    [0.3473980842003284, 0.5611724967369143],
    [0.6577546361903612, 0.12751015085116182],
    [0.5782969020274257, 0.35773271181914923],
    [0.6670711734171612, -0.17639741947050208],
    [0.6999746032576614, -0.005962784104774696],
    [0.5175680184893744, 0.4860281331743907],
    [0.6123143668525683, 0.37877581251439335],
    [0.5883432696468563, -0.4321483507561346],
    [0.7334137462365891, -0.09851028794604497],
    [0.7127522256448591, 0.2334186471520659],
    [0.4821709531692041, -0.5874616344238166],
    [0.5032408896235421, -0.5827937945885376],
    [0.5985729023566386, -0.5001104683610919],
    [0.6367002507137213, -0.46766739328403606],
    [0.6265510948159595, -0.4974271058003608],
    [0.22950766113428267, -0.7768051451172759],
    [0.2519263217025423, -0.7803416741616636],
    [0.2351745169647588, -0.795985519070789],
    [0.5410001909657933, -0.6425875764243937],
    [-0.0850461925218698, -0.8457346777432826],
    [0.5938908916438859, -0.6220077240858277],
    [0.18329792760945268, -0.8504715572751865],
    [-0.022193041326424377, -0.8797201082825631],
    [-0.07797252327337413, -0.8865778508480708],
    [-0.22285718075045974, -0.871971717997756],
    [-0.416357663335547, -0.8091639488890767],
    [-0.2054569752306861, -0.8967649811009897],
    [-0.7632971981012233, -0.5312978330191296],
    [-0.6744601232704335, -0.6547545663208717],
    [-0.3591764977746368, -0.879484077994791],
    [-0.671879700089806, -0.6856950259461079],
    [-0.9666547759723083, -0.08048940358784974],
    [-0.9677816086623221, -0.15426846059700433],
    [-0.9891300335894644, 0.04149429661177983],
    [-0.0, 0.0],
    [-0.009708784271922682, 0.002395727021441877],
    [-0.018078594984529267, 0.008553619314965639],
    [-0.02903423992533784, 0.007550689502152632],
    [-0.035187830398866804, -0.019021477119839703],
    [-0.04770096249510445, 0.014987267163850746],
    [-0.05787518098797863, 0.01582603632021352],
    [-0.06502142482066309, 0.02592709614073391],
    [-0.07900258029896494, -0.012593343722204846],
    [-0.04541027193799972, 0.07770397160066475],
    [-0.07700187981553842, 0.06380211990892916],
    [-0.10165927329796336, 0.04201656997578447],
    [-0.10577099196452469, 0.05667889606229508],
    [-0.006999793103197779, 0.1298114128130205],
    [-0.105536103581712, 0.09198984096513133],
    [0.0012943917812242797, 0.14999441506241723],
    [0.0073780843902885515, 0.15982979656725393],
    [0.005715918027593541, 0.1699038795351708],
    [0.010547244466334274, 0.1796907221705322],
    [0.10070464347168169, 0.16111664961524455],
    [0.11434870020396741, 0.16408648561555336],
    [0.02276733220642103, 0.20876218188216583],
    [-0.04991310137648346, 0.21426311467674716],
    [-0.035250755658212875, 0.22728260871770414],
    [0.005070675232860691, 0.23994642788064777],
    [-0.016580474337799734, 0.24944956979464525],
    [0.04107088687032981, 0.2567356271569737],
    [0.18817530997292037, 0.19362348183160888],
    [0.16858815307787928, 0.22355767632042875],
    [0.18596321333020982, 0.22252569129856203],
    [0.23191387943569883, 0.19030489359205718],
    [0.3093882623420722, -0.01946543410646645],
    [0.2473748047314121, 0.20299188649819436],
    [0.2792136842491679, 0.17589689743712378],
    [0.3314552425866556, 0.0757457732274308],
    [0.3189116033268466, 0.1442060652798631],
    [0.3366472569941324, 0.12754851766416841],
    [0.36988744098006887, 0.009125842712659253],
    [0.3535465203996089, -0.1393013205728111],
    [0.38484106606709917, -0.06322463023489151],
    [0.3721542319995883, -0.14663296902401168],
    [0.3467562007686021, -0.2187695985015402],
    [0.4188087988571179, -0.0316099667804057],
    [0.19011253248791066, -0.3856905819319851],
    [0.20433844107175586, -0.3896739682097904],
    [0.40513598248232613, -0.1958694353340524],
    [0.30347712880178385, -0.3456900812783406],
    [-0.049042827302359905, -0.4674342746207119],
    [0.37463941452285726, -0.30007550564144847],
    [0.14852799480539172, -0.46694692927471937],
    [0.3106745199209716, -0.39176694943789475],
    [-0.14683069149918682, -0.4884063349649253],
    [0.07537442669138195, -0.5145082077099895],
    [-0.1141285164805606, -0.5175661133864413],
    [-0.37476260479730816, -0.3887839889264177],
    [-0.3614346881193116, -0.4145659974287523],
    [-0.09310619292772909, -0.5522057921087978],
    [-0.4651462571829344, -0.3294525146795935],
    [-0.19453579189996761, -0.5464026223123868],
    [-0.5202262229466631, -0.2783247688558262],
    [-0.43747261102210067, -0.41063087390685343],
    [-0.40086392682323657, -0.45979137896643435],
    [-0.3330236410801623, -0.522967737515147],
    [-0.6266117346379642, -0.06525131427030453],
    [-0.6311748361683801, -0.10591660015228455],
    [-0.6396422533030689, -0.11557589623002296],
    [-0.5239099286133222, -0.401395548929462],
    [-0.6021996504067226, -0.2936930047686217],
    [-0.6286120211951671, -0.25932012418809164],
    [-0.6804853702440349, -0.11419133453918177],
    [-0.584084880237416, 0.3858041636349249],
    [-0.43646519914713927, 0.5599983302952327],
    [-0.719702259378637, -0.020704053837009656],
    [-0.40435595033711474, 0.607779783660965],
    [-0.3381381799017007, 0.6582268387818638],
    [-0.14867556357164977, 0.7351160294787844],
    [-0.6124218478842582, 0.45004386478879055],
    [-0.2727321657514232, 0.7200813605173646],
    [-0.5727121742899633, 0.529528814532376],
    [-0.42101230164947445, 0.6684673827942638],
    [0.09016328447403157, 0.7949028759118032],
    [-0.19022194320651972, 0.7873471993490142],
    [-0.3377712581060852, 0.747201831634153],
    [-0.04111458192903909, 0.8289810559673852],
    [0.18777294915598544, 0.8187437447487856],
    [0.5478736825994933, 0.6498726243771702],
    [0.054096169841878816, 0.858296920889525],
    [-0.0322312742077793, 0.8694027518721941],
    [0.3731890516303399, 0.7969503947820394],
    [0.6230296061487481, 0.635558108957896],
    [0.812213083197687, 0.3876982170226065],
    [0.3442403259865885, 0.8423767553563241],
    [0.4812205039450894, 0.7841089379562225],
    [0.572359191261364, 0.7330108840792465],
    [0.9398053261341098, 0.019129792731771997],
    [0.8121973945329658, 0.49278331172419293],
    [0.959858861672613, -0.01646103485679691],
    [0.8292962870494492, 0.5031576972341759],
    [0.7974002627569678, 0.5696953755781416],
    [0.9800148685479799, -0.14025283392818402],
    [0.0, 0.0],
    [0.009784763787293626, 0.002063588531385876],
    [0.019995858002853382, 0.00040701686663373066],
    [0.02772271130868992, -0.011465220350915014],
    [0.017977965066172975, -0.03573223715469638],
    [0.03642564448938745, -0.03425160468551449],
    [0.032183132165479786, -0.050638384690067484],
    [0.04916226217275431, -0.04983043224834972],
    [0.004289827510560424, -0.0798849008256857],
    [0.02798174949316899, -0.0855395913907796],
    [0.05043668609853033, -0.08634894727440698],
    [0.050663805194413894, -0.09763799897182693],
    [0.05922409446116128, -0.10436717221068817],
    [0.04349406054392218, -0.12250823114142831],
    [0.04018737118588627, -0.13410807282623888],
    [-0.05617415874436985, -0.1390843768701659],
    [-0.11981878589391054, -0.10603517598848614],
    [0.006993283871131765, -0.16985609786138905],
    [-0.08373454857213547, -0.1593377713394432],
    [-0.08201868649628744, -0.17138534087086832],
    [-0.12045556249720987, -0.15965731259006202],
    [-0.1777062848767807, -0.11189493427002171],
    [-0.1735356229145854, -0.1352234727391914],
    [-0.08879269543531539, -0.21216940693071504],
    [-0.22110648419028245, -0.09333768075655412],
    [-0.12721315504924977, -0.2152134131099072],
    [-0.25752623543326275, 0.03578041452487308],
    [-0.25789652079749614, 0.07993362596896678],
    [-0.27506351309596155, 0.052345618377356344],
    [-0.28980210827266634, -0.01071158441678137],
    [-0.2966561635244233, -0.044666773366459765],
    [-0.28852034667251275, -0.11338434440421277],
    [-0.31508151683322266, 0.05588951377562431],
    [-0.32997187852775706, 0.004308059988350078],
    [-0.3361539107463854, 0.050995571277428105],
    [-0.26756956291343126, 0.22562475263657455],
    [-0.22362301773456078, 0.2821218636321695],
    [-0.28873318208113274, 0.2313723180618277],
    [-0.13306055662719948, 0.35594225412285624],
    [-0.193864891854347, 0.3384027241413734],
    [-0.16319228178730655, 0.365196220085932],
    [-0.018542576869232042, 0.40958048396261365],
    [-0.27701772416515774, 0.3156915907944916],
    [-0.2542837378420356, 0.34675608238224614],
    [-0.041842815020411914, 0.43800591186782833],
    [0.0077660615234086934, 0.449932981996669],
    [-0.07226042546700437, 0.4542889288892343],
    [0.2999904838766453, 0.36180894071796577],
    [0.29704081061758014, 0.37705007204302604],
    [0.23696219142589153, 0.4288926670329529],
    [0.23078259672964796, 0.4435531456846191],
    [0.01517473337079581, 0.5097741926256423],
    [0.1867103440914724, 0.48532385827326086],
    [0.267822352106699, 0.45735236712193317],
    [0.42458910942872513, 0.3336526459576222],
    [0.29552719955350526, 0.4638573857599585],
    [0.5599964959999316, 0.0019810269556172137],
    [0.4107781515048431, 0.3951725069463518],
    [0.5742409941194739, 0.08153085718106141],
    [0.5482315948056299, 0.21804155213370693],
    [0.5989573311704842, -0.035356971549205064],
    [0.6094864273873248, 0.02502588321389601],
    [0.6193309051690751, -0.028796352242159935],
    [0.5075826321037733, -0.3731753898458551],
    [0.4531976055295885, -0.4518981415565326],
    [0.5422849734532336, -0.3583671407465063],
    [0.6599151247675467, 0.010584332904526404],
    [0.47444124328879306, -0.47308086694199],
    [0.45059296067308324, -0.5092798678446515],
    [0.654654313249762, -0.21800855520709062],
    [0.4831746848866501, -0.5064999742198285],
    [0.09684916886206907, -0.7033635180265799],
    [-0.04544936714898611, -0.7185640924968052],
    [0.4486321382495598, -0.5758725592782039],
    [0.11923501329552644, -0.730330754935335],
    [0.3673327018484025, -0.6538858357180963],
    [-0.3480273466578689, -0.6756307911709503],
    [-0.11557448762793583, -0.7612769126996699],
    [0.1924716258724739, -0.7558800653767813],
    [-0.55315152876638, -0.564024278044321],
    [-0.5879996944389281, -0.5424540158757496],
    [0.14049624574931158, -0.7977222605207591],
    [-0.5441797850545269, -0.6134071743450754],
    [-0.7878313940029266, -0.2611928303445681],
    [-0.24877146637404754, -0.8023171178019992],
    [-0.6855038700436717, -0.5025777991069141],
    [-0.5626391440733599, -0.650413094545611],
    [-0.7204256923751131, -0.48773642653162574],
    [-0.8352911165332194, -0.2769273381966624],
    [-0.8885224567621138, -0.051262499250607864],
    [-0.751516506636479, -0.4951998992860399],
    [-0.8601199618187741, -0.2971424763995744],
    [-0.8362984205551839, 0.3834122478180709],
    [-0.9165733384095777, -0.15745893215922335],
    [-0.9398582000364308, 0.01632678242279759],
    [-0.9025565340785804, 0.29646534838335076],
    [-0.8915644079285658, 0.35596756385236433],
    [-0.6366272534926078, 0.7318509001910567],
    [-0.7846647130682821, 0.5871126706735869],
    [-0.8348842324537958, 0.5320416510011574],
]
y = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
]

npx = np.array(X)
npy = np.array(y)
plt.scatter(npx[:, 0], npx[:, 1], c=npy, s=40, cmap=plt.cm.Spectral)
plt.show()
