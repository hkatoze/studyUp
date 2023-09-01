import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import "package:flutter/material.dart";
import 'package:study_up/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  final String link;
  final String title;
  const WebViewExample({Key? key, required this.link, required this.title});
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    void curruntPage(int position) {
      if (position == 0) {}
      if (position == 1) {}

      if (position == 2) {
        AwesomeDialog(
          btnOkText: "Valider",
          btnOkColor: Color(0xFF262160),
          customHeader: Icon(
            Icons.app_settings_alt_outlined,
            size: 60,
            color: Color(0xFFf4931d),
          ),
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.INFO,
          body: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          title: 'This is Ignored',
          desc: 'This is also Ignored',
          btnOkOnPress: () {},
        )..show();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: kPrimaryColor,
        title: Text(widget.title.toString()),
        centerTitle: true,
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.link,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}

class Appropos extends StatefulWidget {
  const Appropos({Key? key}) : super(key: key);

  @override
  State<Appropos> createState() => _ApproposState();
}

class _ApproposState extends State<Appropos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: kPrimaryColor,
        title: Text("À propos de StudyUp"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              Container(
                height: heightP(context, 0.5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/about.png")),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "StudyUp est une plateforme numérique ( essentiellement mobile) composée d'une large gamme de collection de documents numériques ou audios (c'est-à-dire numérisés ) accessibles à distance (en particulier via Playstore ou App store), proposant différentes modalités d'accès à l'information aux publics. Les documents sont constitués par catégories ou domaines (développement personel, littérature, roman, livre pédagogique etc ...)",
                  style: TextStyle(fontSize: 17),
                ),
              )
            ],
          )),
    );
  }
}

class Politics extends StatefulWidget {
  const Politics({Key? key}) : super(key: key);

  @override
  State<Politics> createState() => _PoliticsState();
}

class _PoliticsState extends State<Politics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: kPrimaryColor,
        title: Text("Conditions d'utilisation & de Services"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Bienvenue sur la plateforme StudyUp, qui appartient et est exploitée par Smart Touch Group. Ces conditions constituent un contrat entre vous et l’entreprise Smart Touch Group. En utilisant StudyUp, en créant votre compte sur les plateformes mobiles ou sur le site StudyUp vous acceptez ces conditions d'utilisation. Si vous n'acceptez aucune de ces conditions, vous ne pouvez pas utiliser les Services StudyUp.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                height: heightP(context, 0.5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/using.png")),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Vous devez avoir 18 ans",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Les services de StudyUp sont réservés aux personnes de 18 ans et plus. Si nous apprenons qu'une personne de moins de 18 ans utilise les services de StudyUp, nous résilierons son compte.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Vous avez besoin d'un compte",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Pour tirer le meilleur parti de la plateforme StudyUp, vous devrez vous inscrire, choisir un nom de compte et définir un mot de passe.Vous êtes responsable de toutes les activités sur votre compte et de la confidentialité de votre mot de passe. Si vous partagez les informations de votre compte avec quelqu'un, cette autre personne peut être en mesure de prendre le contrôle du compte, et nous ne pourrons peut-être pas déterminer qui est le titulaire du compte. Nous n'aurons aucune responsabilité envers vous (ou toute personne avec qui vous partagez les informations de votre compte) à la suite de vos actions ou de leurs actions dans ces circonstances. Si vous découvrez que quelqu'un a utilisé votre compte sans votre permission, vous devez le signaler sur contact@smt-group.net.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Nos droits sur les services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Nous nous réservons tous les droits sur l'aspect et la convivialité de notre plateforme et des services, ainsi que sur notre contenu. Vous ne pouvez copier ou adapter aucune partie de notre code ou des éléments de conception visuelle (y compris les logos) sans l'autorisation écrite expresse de StudyUp ou comme indiqué dans cette clause. Veuillez ne pas utiliser notre logo ou nos marques commerciales d'une manière qui pourrait suggérer que StudyUp approuve un produit ou un service particulier, ou que vous avez une relation commerciale avec StudyUp.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Veuillez ne pas modifier, étirer, condenser, embellir, ajouter des étincelles ou autrement modifier notre logo de quelque manière que ce soit. Nous sommes assez fiers de notre logo, et nous aimerions le garder tel quel.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "StudyUp peut modifier, résilier ou restreindre l'accès à tout aspect des Services, à tout moment, sans préavis. StudyUp peut accéder, lire, conserver et divulguer toute information que nous estimons raisonnablement nécessaire pour (i) satisfaire à toute loi, réglementation, procédure judiciaire ou demande gouvernementale applicable, (ii) appliquer les Conditions d'utilisation, y compris les enquêtes sur les violations potentielles, (iii) détecter, prévenir ou résoudre les problèmes de fraude, de sécurité ou techniques, (iv) répondre aux demandes d'assistance des utilisateurs, ou (v) protéger les droits, la propriété ou la sécurité des Services, de ses utilisateurs et du public.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Choses que vous devriez et ne devriez pas faire",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Des grands nombres de personnes utilisent la plateforme. Nous nous attendons à ce que chacun d'eux se comporte de manière responsable et aide à garder cet endroit agréable. Ne faites aucune de ces choses sur les Services :",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "N'enfreignez pas la loi.",
                      children: [
                        TextSpan(
                            text:
                                "N'entreprenez aucune action qui enfreint ou viole les droits d'autrui, viole la loi ou enfreint tout contrat ou obligation légale que vous avez envers quiconque.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "N'endommagez l'ordinateur de personne.",
                      children: [
                        TextSpan(
                            text:
                                "Ne distribuez pas de virus logiciels ou quoi que ce soit d'autre (code, films, programmes) conçu pour interférer avec le bon fonctionnement de tout logiciel, matériel ou équipement sur la plateforme (qu'il appartienne à StudyUp ou à quelqu'un d'autre).",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text:
                          "N'essayez pas d'endommager ou de perturber StudyUp.",
                      children: [
                        TextSpan(
                            text:
                                "N'essayez pas d'interférer avec le bon fonctionnement des Services. Ne contournez aucune des mesures que nous avons mises en place pour sécuriser les Services. N'essayez pas d'endommager ou d'obtenir un accès non autorisé à un système, à des données, à un mot de passe ou à d'autres informations. N'entreprenez aucune action qui impose une charge déraisonnable à notre infrastructure ou à nos fournisseurs tiers. (Nous déterminons ce qui est raisonnable.)",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Ne grattez pas StudyUp.",
                      children: [
                        TextSpan(
                            text:
                                "N'utilisez aucun type de logiciel, d'appareil ou de méthode (qu'il soit manuel ou automatisé) pour 'explorer', 'spider' ou autrement supprimer tout contenu de toute partie du site ou des services. Ne faites aucune utilisation de la plateforme, du contenu ou des Services qui pourrait avoir pour effet de concurrencer ou de déplacer le marché de StudyUp, ou des Services.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text:
                          "Ne volez aucun contenu de StudyUp sans autorisation.",
                      children: [
                        TextSpan(
                            text:
                                "Ne modifiez pas, ne traduisez pas, ne reproduisez pas, ne distribuez pas ou ne créez pas d'autres œuvres dérivées de tout contenu à moins d'obtenir le consentement explicite de l'auteur de ce contenu.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text:
                          "Ne volez pas la précieuse propriété intellectuelle de StudyUp.",
                      children: [
                        TextSpan(
                            text:
                                "Ne démontez pas ou n'effectuez pas d'ingénierie inverse sur tout aspect de la plateforme ou des services dans le but d'accéder à des éléments tels que le code source, les idées sous-jacentes ou les algorithmes.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Ne faites aucun usage commercial de StudyUp.",
                      children: [
                        TextSpan(
                            text:
                                "StudyUp est réservé à votre usage personnel et non commercial. Ne vendez en aucun cas l'accès à la plateforme ou aux Services. N'utilisez pas la plateforme ou les Services dans le but de faire la publicité de biens ou de services.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Avis de non-responsabilité, limitations de responsabilité et indemnisation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Chacune des sous-sections ci-dessous ne s'applique que dans la mesure maximale autorisée par la loi applicable. Certaines juridictions n'autorisent pas l'exclusion de garanties implicites ou la limitation de responsabilité dans les contrats, et par conséquent, le contenu de cette section peut ne pas s'appliquer à vous. Rien dans cette section n'est destiné à limiter les droits que vous pourriez avoir et qui ne peuvent pas être légalement limités.",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Aucune garantie.",
                      children: [
                        TextSpan(
                            text:
                                "Votre utilisation de nos Services et de tout contenu est à vos propres risques et à votre seule discrétion. Ils vous sont fournis « tels quels » et « tels que disponibles ». Cela signifie qu'ils ne sont accompagnés d'aucune garantie d'aucune sorte, expresse ou implicite. StudyUp décline spécifiquement toute garantie implicite de qualité marchande, de qualité marchande, d'adéquation à un usage particulier, de disponibilité, de sécurité, de titre ou de non-contrefaçon, et toute garantie implicite par tout cours de transaction ou de performance.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Responsabilité du contenu. ",
                      children: [
                        TextSpan(
                            text:
                                "Tout contenu, qu'il soit publié publiquement ou transmis en privé, relève de la seule responsabilité de la personne à l'origine de ce contenu. Nous ne pouvons pas surveiller ou contrôler le contenu publié via les Services et nous ne pouvons pas assumer la responsabilité d'un tel contenu. Nous n'approuvons, ne soutenons, ne représentons ni ne garantissons l'exhaustivité, la véracité, l'exactitude ou la fiabilité de tout contenu ou communication publiée via les Services, ni n'approuvons les opinions exprimées via les Services. Vous comprenez qu'en utilisant les Services, vous pouvez être exposé à du contenu qui pourrait être offensant, préjudiciable, inexact ou autrement inapproprié, ou dans certains cas, à des publications mal étiquetées ou autrement trompeuses.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Relâchez.",
                      children: [
                        TextSpan(
                            text:
                                "Lorsque vous utilisez les Services, vous libérez StudyUp de toute réclamation, dommage et demande de toute nature — connue ou inconnue, suspectée ou non, divulguée ou non divulguée — découlant de ou liée de quelque manière que ce soit à (a) des litiges entre utilisateurs, ou entre les utilisateurs et tout tiers concernant l'utilisation des Services et (b) les Services.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "La responsabilité de StudyUp envers vous ",
                      children: [
                        TextSpan(
                            text:
                                "Ne sera pas responsable envers vous des dommages résultant de votre utilisation ou en relation avec les Services et tout contenu. Cette exclusion comprend : (a) lorsque les Services sont piratés ou indisponibles, (b) tous les types de dommages (directs, indirects, punitifs, accessoires, consécutifs, spéciaux ou exemplaires), quel que soit le type de réclamation ou de perte (rupture de contrat, délit (y compris la négligence), rupture de garantie ou toute autre réclamation ou perte), (c) toute perte de bénéfices, de données ou de revenus, ou (d) tout comportement ou contenu d'autres utilisateurs ou de tiers sur le Site ou les Services.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Votre responsabilité envers StudyUp.",
                      children: [
                        TextSpan(
                            text:
                                "Si vous faites quelque chose qui nous fait poursuivre en justice ou si vous rompez l'une des promesses que vous faites dans les présentes Conditions d'utilisation, vous devez nous indemniser pour toute responsabilité, perte, réclamation et dépense (y compris les frais et coûts juridiques raisonnables) découlant de ou liés à votre utilisation ou mauvaise utilisation des Services. Nous nous réservons le droit d'assumer la défense et le contrôle exclusifs de toute question autrement soumise à cette clause, auquel cas vous acceptez de coopérer et de nous aider à faire valoir toute défense.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Sites Web tiers .",
                      children: [
                        TextSpan(
                            text:
                                "Le Site et les Services peuvent contenir des liens vers d'autres sites Web ; par exemple, les histoires, les profils d'utilisateurs et d'autres messages peuvent être liés à d'autres sites. Lorsque vous accédez à des sites Web tiers, vous le faites à vos risques et périls. Nous ne contrôlons ni n'approuvons ces sites.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Conditions générales",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Changements.",
                      children: [
                        TextSpan(
                            text:
                                "Nos conditions d'utilisation peuvent changer de temps à autre. Si tel est le cas, nous vous informerons de tout changement important, soit en vous en informant sur le Site, soit en vous envoyant un e-mail. Veuillez noter que votre utilisation continue des Services après toute modification signifie que vous acceptez et consentez à être lié par les nouvelles Conditions d'utilisation. Si vous n'êtes pas d'accord avec les modifications apportées aux Conditions d'utilisation et que vous ne souhaitez pas être soumis aux conditions révisées, vous devrez fermer votre compte et/ou cesser d'utiliser les Services.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Entente intégrale.",
                      children: [
                        TextSpan(
                            text:
                                "Ces Conditions d'utilisation (y compris tout document incorporé par référence dans celles-ci) constituent l'intégralité de l'accord entre StudyUp et vous concernant les Services, et ces Conditions d'utilisation annulent et remplacent tout accord antérieur entre StudyUp et vous concernant les Services.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Aucune renonciation et divisibilité.",
                      children: [
                        TextSpan(
                            text:
                                "Si StudyUp n'exerce pas ou n'applique pas un droit ou une disposition particulière en vertu des présentes Conditions d'utilisation, cela ne signifie pas que nous avons renoncé à ce droit ou à cette disposition. Si une disposition des présentes Conditions d'utilisation est jugée invalide ou inapplicable, cette disposition sera limitée ou supprimée dans la mesure minimale nécessaire, et les autres dispositions des présentes Conditions d'utilisation resteront en vigueur et de plein effet.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Choix de la loi et de la juridiction.",
                      children: [
                        TextSpan(
                            text:
                                "Chez StudyUp, nous vous encourageons à nous contacter si vous rencontrez un problème, avant de recourir aux tribunaux. Dans le cas malheureux où une action en justice surviendrait, les présentes conditions d'utilisation seront régies et interprétées conformément aux lois. Vous acceptez que tout litige ou réclamation découlant de ou en relation avec ces conditions d'utilisation aura lieu devant les tribunaux.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                      text: "Affectation.",
                      children: [
                        TextSpan(
                            text:
                                "Ces conditions d'utilisation vous sont personnelles. Vous ne pouvez pas les céder, les transférer ou les concéder en sous-licence sans l'accord écrit préalable de StudyUp. StudyUp a le droit de céder, transférer ou déléguer l'un de ses droits et obligations en vertu des présentes Conditions d'utilisation sans préavis et sans votre consentement.",
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Fin...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor),
                ),
              )
            ],
          )),
    );
  }
}
