import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/util/SharedPrefs.dart';

BuildContext ctx;

class PictureGrid extends StatefulWidget {
  @override
  _PictureGridState createState() => new _PictureGridState();
}

class _PictureGridState extends State<PictureGrid> {
  List<String> urls;

  @override
  initState() {
    super.initState();
    print('################# initState');
    loadUrls();
  }

  void loadUrls() {
    urls = new List<String>();
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F0ae2b4a2fd6512bff7d9b5068a5aace7--people-portraits-women-portraits.jpg?alt=media&token=6c8b0ed5-7013-4831-9f64-b6c6e2aca2e5');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F14875138939_25a900cc25_b.jpg?alt=media&token=32701b23-c5c0-42d6-8a24-c00001d334ad');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F49535-confident-woman-unsplash.400w.tn.jpg?alt=media&token=519ebfb4-88c0-440f-8b40-eff3e762b63c');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F5629908240_12b0ea3422_o.jpg?alt=media&token=7556dd5c-26f2-463a-829b-1d92a32c2bc5');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F5708.jpg?alt=media&token=c0d17383-2f4f-428b-8fac-8148b66dcf39');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F5e733b0c87aa459fbb872edb9f892587.png?alt=media&token=aea63d17-8286-43c6-ab47-be8cb6c0398e');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2F86e21287e87a4bee9c5514766c612393.png?alt=media&token=f503246a-11e2-479b-8db6-6bd7606eca72');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fafrican-lion-2888519_960_720.jpg?alt=media&token=4dfcea7a-1e0b-4259-94f0-df7d3329b0f3');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2FAngelina1.jpg?alt=media&token=e0e40704-93fc-40da-9e9e-ae8080940a9e');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fanimal-2923186_960_720.jpg?alt=media&token=bce6d3c5-accf-4d0d-a605-cb47fb803074');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Funnamed1.png?alt=media&token=704317d3-7468-4ec1-a049-741aa4112d2d');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fw3.jpg?alt=media&token=1a47b713-41b3-4a5a-82d9-9e37432db027');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fw4.jpg?alt=media&token=512e330d-5c1b-4238-a3c4-4e37e0163ba0');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fwebsite-banner-700x400.jpg?alt=media&token=6f4cd813-69dc-4236-b3a1-20325c1332da');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2FyzbEADpS_400x400.jpg?alt=media&token=1fd9c571-7592-46fe-ad18-19764c554918');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2FZandile-ubuhle-beads.jpg?alt=media&token=f1bcba0b-8069-4b2e-a81b-e6b685e97c60');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2F1612jpg.jpg?alt=media&token=69e810be-8c20-4f65-9c79-0cf94508193a');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2F170111203708-michelle-obama-2-large-169.jpg?alt=media&token=67977eb8-6f8b-4cab-a7b0-83e65ac24f3f');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2F52664-098.jpg?alt=media&token=4b3338d7-211b-41fd-aedb-f3bfe9174f38');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2F587cfd3f1200002d00ad7d69.jpeg?alt=media&token=13dc0d52-a3a8-49d1-a466-4bb9a07eaf0f');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2FBlack-Panther-Movie-Character-Portraits.jpg?alt=media&token=37c6c3b1-72a2-45a1-b2c9-3332b13f51b7');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fdepositphotos_95551812-stock-photo-portrait-of-a-very-beautiful.jpg?alt=media&token=834e1277-e2de-45e0-87c0-482949c35aab');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2FDSC2449-Landscape-1024x683.jpg?alt=media&token=4214e9e3-3144-49e5-8de4-459b055cc918');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2FFebruary_27_LucretiaDaltPLI_SamAshley_SiteLandscape.cEbeeE.jpg?alt=media&token=8e1c1a44-7dae-4cf2-9886-9dbd18155897');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fglasses.jpg?alt=media&token=1fdbb12f-b222-443c-9767-94b20261c13b');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fhomeless-male-b-w-poverty.jpg?alt=media&token=a8e8cdeb-8e8e-4666-881a-3635465b7b84');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fian-van-der-wolde_orig.jpg?alt=media&token=cd853832-4d6c-4c58-ad0c-37ce66b9f40a');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fjanaye-ingram_2012-640-landscape.jpg?alt=media&token=ade3ae20-c792-44e0-8d59-15f222da9819');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fkid.jpg?alt=media&token=7949edfd-5155-4dfa-a040-8bfc7f4b4fad');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1433354204-gettyimages-solage.jpg?alt=media&token=18e06b5c-d650-4df1-a212-33700f5e198b');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1470573043-credit-rachell-smith-2.jpeg?alt=media&token=08c25541-61ea-425d-a73a-430b56f84d5b');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1473436815-the-x-factor-2016-auditions-gifty-agyeman%20(1).JPG?alt=media&token=b6360867-7f6f-4470-b2eb-cc61f0021d0f');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1478207285-common.jpg?alt=media&token=82eec254-4f77-42da-8e0e-19c036e1c1aa');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1479735660-designer-portrait.jpg?alt=media&token=b56fccd6-2d72-422f-93e1-5cd4795c1653');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1481544475-gettyimages-168867537.jpg?alt=media&token=91be70bc-0ee3-4e9e-be05-3675d58543bf');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-1494195157-index-03-rs.jpg?alt=media&token=8303828c-3ccf-43e1-ad47-045694617d74');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Flandscape-original-black-opium-edie-campbell-jpg-73068f62.jpg?alt=media&token=fc3085c1-ff47-459c-9b8c-7360c7b58f57');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fkidincap.jpg?alt=media&token=16d581ba-c402-4377-84cd-96058bf69f15');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2FLandscapes-of-Exclusion.jpg?alt=media&token=2e31beda-c0e0-4965-9ba2-3e942adc0a71');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fmatthew-mcconaughey-dark-tower-first-look.jpg?alt=media&token=ac987a46-fe51-4362-831e-a452723b9243');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fmlk-s-dream-and-the-nightmare-of-black-genocide.jpg?alt=media&token=4044d294-c52d-456d-bc5c-123c1208cc1e');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2FModelshoot-Portrait-Karo-blackandwhite-Landscapeformat-www.melaniesphototales.com_.jpg?alt=media&token=2a617e76-e6be-44a2-b419-8704983bc5ef');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fmusk1.jpg?alt=media&token=1db6404e-4097-45af-a8fb-e65494dcaa6e');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fobama.jpeg?alt=media&token=b3c9f50f-0414-4453-9109-e51c2f7f411a');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Foldguy.jpg?alt=media&token=e034b32d-0770-45da-bcde-eaa047794c67');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fpanther2.jpg?alt=media&token=5d7b4f23-d4eb-46f7-8323-b33a02101f18');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fpanther4.jpg?alt=media&token=722360dc-9bd1-43d7-a4f9-9915e1ce7e28');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fpexels-photo-893165.jpeg?alt=media&token=17dd93d8-f230-4666-b530-8daed35e614b');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fselfie1.jpg?alt=media&token=a94eb753-f292-454d-a35d-f00925edd4d1');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fslick.jpg?alt=media&token=0ea2f36e-c84e-47b3-bbea-e10a23b0f083');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fwhitegirlhat.jpeg?alt=media&token=2affb6e0-c7c7-4327-9925-1a9b1c3e43b6');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fwhitemilf.jpg?alt=media&token=baeae81d-6fd9-4a7b-b97a-c2fadfc9c352');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/images%2Fwillem_dafoe_bw2.jpg?alt=media&token=cb2e474b-6143-4e85-9afc-2d0b273c7a50');
    //////
    //urls.add(
    //    'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fblackguy.jpg?alt=media&token=8fb990db-67d7-430c-9c71-55ae2a24f937');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fdc08051156c4b3890d51c1b84d900199.jpg?alt=media&token=1615df16-d136-47ea-9865-74fa76ec47df');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fdfdfs.jpg?alt=media&token=44c06833-10fa-4b72-9552-070a6e9b354b');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fdownloadx.jpeg?alt=media&token=22afab14-d3e9-4661-adf0-bbbc72a2eaa9');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fdownloadxx.jpeg?alt=media&token=703adfb9-7fdc-4c6d-b3a5-1c07168b8466');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2FDVhzIZpVMAAgQhJ.jpg?alt=media&token=c4db240d-ebcb-419f-95fc-b824e0459a5d');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Ff6f45646f34efeae61f05c177f76fced--amazing-eyes-beautiful-eyes.jpg?alt=media&token=4a72a206-6a9b-40e3-861c-9a8657cf372b');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Ffacial-expression-3165663_960_720.jpg?alt=media&token=f6e520af-348d-43ab-bce7-1d71361e2e27');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Ffemale1.jpg?alt=media&token=a86318d6-e620-4505-87c1-2422e066af29');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Ffemale2.jpg?alt=media&token=dfafc765-68ed-400a-b3ef-d19d0a62788c');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Ffemale3.jpg?alt=media&token=b95ad9a6-8180-4c31-aa32-2048394ddad6');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fhaki_madhubuti_photo_courtesy_third_world_press.jpg?alt=media&token=c0b07572-1ced-4c9e-b456-ec56a07cb872');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fhijab-3064633_960_720.jpg?alt=media&token=ca69c20a-f5d3-4737-a65e-6cd6e0c2ed63');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fhttp_%252F%252Fo.aolcdn.com%252Fhss%252Fstorage%252Fmidas%252F2de2cb5aa8bf4255f186e3cbb7ead09c%252F205965779%252Fsteve%2Bbiko.jpg?alt=media&token=53cf210a-f4f4-4990-a1cc-9acc2a36eeaf');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fimages.jpeg?alt=media&token=8d76d2bb-a1f5-4ab9-80d8-d2dd527aa606');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fimagesali.jpeg?alt=media&token=ab647eff-7a50-47c9-84e3-a08b26320173');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fkak-ubrat-vesnushki-s-litsa-640x427.jpg?alt=media&token=d6be82a0-8806-4c7d-ad12-56d36c503efc');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fkenrya.jpg?alt=media&token=e8a76bdc-f1e9-476f-83fa-8b8e0afaf56c');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Flion-3040797_960_720.jpg?alt=media&token=ca9cb41f-3eec-451d-ae37-caed43ad416e');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fmaxresdefault.jpg?alt=media&token=4b9a8fe0-fdd9-451b-91c0-c7a4b233f4eb');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fmaxresdefaultxsd.jpg?alt=media&token=dda565f8-ae8c-425c-be86-b635b7a179db');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fmeghan-markle-1017-ss07.jpg?alt=media&token=dbeb8d24-bdec-4386-a433-7b47400d42cd');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fgirl-3033718_960_720.jpg?alt=media&token=9e855e4d-149f-4007-a75e-b4e4a220dfb7');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2FNaledi-Mashishi-bio-pic.jpg?alt=media&token=212a6266-335b-45f4-8887-86ceb5895da6');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fogt7uy.png?alt=media&token=9b9b58af-f610-4d29-be98-271fb259a396');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2FPortraiture-Photography-By-Famous-Photographers-05.jpg?alt=media&token=95139b5b-83ce-4239-8a8f-9f82c9a980d7');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Frihanna-fenty-beauty.png?alt=media&token=344afdec-c9ca-4688-b2dc-b24550930234');
    urls.add(
        'https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/photos%2Fthenewyorker_the-new-yorker-festival-chimamanda-ngozi-adichie-tk.jpg?alt=media&token=a213ba0b-30e8-4e87-a9bd-155953de8342');
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Select Picture"),
        ),
        body: new Container(
          color: Colors.purple.shade900,
          child: new GridView.count(
            crossAxisCount: 3,
            primary: false,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 4.0,
            padding: new EdgeInsets.all(20.0),
            children: <Widget>[
              new GestureDetector(
                onTap: _onTap0,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(0)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap1,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(1)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap2,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(2)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap3,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(3)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap4,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(4)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap5,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(5)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap6,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(6)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap7,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(7)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap8,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(8)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap9,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(9)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap10,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(10)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap11,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(11)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap12,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(12)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap13,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(13)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap14,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(14)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap15,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(15)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap16,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(16)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap17,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(17)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap18,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(18)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap19,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(19)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
              new GestureDetector(
                onTap: _onTap20,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(urls.elementAt(20)),
                  radius: 50.0,
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ));
  }

  _onTap0() {
    print('SELECTED index: 0');
    _navigate(urls.elementAt(0));
  }

  _onTap1() {
    print('SELECTED index: 1');
    _navigate(urls.elementAt(1));
  }

  _onTap2() {
    print('SELECTED index: 2');
    _navigate(urls.elementAt(2));
  }

  _onTap3() {
    print('SELECTED index: 3');
    _navigate(urls.elementAt(3));
  }

  _onTap4() {
    print('SELECTED index: 4');
    _navigate(urls.elementAt(4));
  }

  _onTap5() {
    print('SELECTED index: 5');
    _navigate(urls.elementAt(5));
  }

  _onTap6() {
    print('SELECTED index: 6');
    _navigate(urls.elementAt(6));
  }

  _onTap7() {
    print('SELECTED index: 7');
    _navigate(urls.elementAt(7));
  }

  _onTap8() {
    print('SELECTED index: 8');
    _navigate(urls.elementAt(8));
  }

  _onTap9() {
    print('SELECTED index: 9');
    _navigate(urls.elementAt(9));
  }

  _onTap10() {
    print('SELECTED index: 10');
    _navigate(urls.elementAt(10));
  }

  _onTap11() {
    print('SELECTED index: 11');
    _navigate(urls.elementAt(11));
  }

  _onTap12() {
    print('SELECTED index: 12');
    _navigate(urls.elementAt(12));
  }

  _onTap13() {
    print('SELECTED index: 13');
    _navigate(urls.elementAt(13));
  }

  _onTap14() {
    print('SELECTED index: 14');
    _navigate(urls.elementAt(14));
  }

  _onTap15() {
    print('SELECTED index: 15');
    _navigate(urls.elementAt(15));
  }

  _onTap16() {
    print('SELECTED index: 16');
    _navigate(urls.elementAt(16));
  }

  _onTap17() {
    print('SELECTED index: 17');
    _navigate(urls.elementAt(17));
  }

  _onTap18() {
    print('SELECTED index: 18');
    _navigate(urls.elementAt(18));
  }

  _onTap19() {
    print('SELECTED index: 19');
    _navigate(urls.elementAt(19));
  }

  _onTap20() {
    print('SELECTED index: 20');
    _navigate(urls.elementAt(20));
  }

  _navigate(String url) {
    SharedPrefs.savePictureUrl(url);

    Navigator.pop(ctx, url);
  }
}
