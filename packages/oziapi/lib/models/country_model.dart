class CountryModel {
  CountryModel({
    required this.name,
    required this.tld,
    required this.cca2,
    required this.ccn3,
    required this.cca3,
    required this.independent,
    required this.status,
    required this.unMember,
    required this.currencies,
    required this.idd,
    required this.capital,
    required this.altSpellings,
    required this.region,
    required this.subregion,
    required this.languages,
    //required this.translations,
    required this.latlng,
    required this.landlocked,
    required this.area,
    required this.demonyms,
    required this.flag,
    required this.maps,
    required this.population,
    required this.car,
    required this.timezones,
    required this.continents,
    required this.flags,
    required this.coatOfArms,
    required this.startOfWeek,
    required this.id,
    //required this.capitalInfo,
    //required this.postalCode,
  });
  late final Name name;
  late final List<String> tld;
  late final String cca2;
  late final String ccn3;
  late final String cca3;
  late final bool independent;
  late final String status;
  late final bool unMember;
  late final Currencies? currencies;
  late final Idd idd;
  late final List<String> capital;
  late final List<String> altSpellings;
  late final String region;
  late final String subregion;
  late final Languages? languages;
  //late final Translations translations;
  late final List<double> latlng;
  late final bool landlocked;
  late final double area;
  late final Demonyms? demonyms;
  late final String flag;
  late final Maps maps;
  late final int population;
  late final Car car;
  late final List<String> timezones;
  late final List<String> continents;
  late final Flags flags;
  late final CoatOfArms coatOfArms;
  late final String startOfWeek;
  late final String id; // this is Shared.userInfo.user?.countryId
  //late final CapitalInfo capitalInfo;
  //late final PostalCode postalCode;

  static CountryModel getDefault() {
    return CountryModel(
      name: Name(
        common: "Unknown",
        official: "Unknown Country",
      ),
      tld: [],
      cca2: "UN",
      ccn3: "000",
      cca3: "UNK",
      independent: false,
      status: "unknown",
      unMember: false,
      currencies: null,
      idd: Idd(root: "+0", suffixes: []),
      capital: [],
      altSpellings: ["Unknown"],
      region: "Unknown",
      subregion: "Unknown",
      languages: null,
      latlng: [0.0, 0.0],
      landlocked: false,
      area: 0.0,
      demonyms: null,
      flag: "🏳️",
      maps: Maps(
        googleMaps: "https://www.example.com",
        openStreetMaps: "https://www.example.com",
      ),
      population: 0,
      car: Car(signs: [], side: "right"),
      timezones: ["UTC"],
      continents: ["Unknown"],
      flags: Flags(
        png: "",
        svg: "",
      ),
      coatOfArms: CoatOfArms(),
      startOfWeek: "monday",
      id: "unknown",
    );
  }

  CountryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = Name.fromJson(json['name']);
    tld = List.castFrom<dynamic, String>(json['tld'] ?? []);
    cca2 = json['cca2'];
    ccn3 = json['ccn3'] ?? '';
    cca3 = json['cca3'];
    independent = json['independent'] ?? false;
    status = json['status'];
    unMember = json['unMember'];
    currencies = json['currencies'] != null
        ? Currencies.fromJson(json['currencies'])
        : null;
    idd = Idd.fromJson(json['idd']);
    //capital = List.castFrom<dynamic, String>(json['capital']);
    altSpellings = List.castFrom<dynamic, String>(json['altSpellings']);
    region = json['region'];
    subregion = json['subregion'] ?? '';
    languages = json['languages'] != null
        ? Languages.fromJson(json['languages'])
        : null;
    //translations = Translations.fromJson(json['translations']);
    latlng = List.castFrom<dynamic, double>(json['latlng']);
    landlocked = json['landlocked'];
    area = json['area'];
    demonyms =
        json['demonyms'] != null ? Demonyms.fromJson(json['demonyms']) : null;
    flag = json['flag'];
    maps = Maps.fromJson(json['maps']);
    population = json['population'];
    car = Car.fromJson(json['car']);
    timezones = List.castFrom<dynamic, String>(json['timezones']);
    continents = List.castFrom<dynamic, String>(json['continents']);
    flags = Flags.fromJson(json['flags']);
    coatOfArms = CoatOfArms.fromJson(json['coatOfArms']);
    startOfWeek = json['startOfWeek'];
    //capitalInfo = CapitalInfo.fromJson(json['capitalInfo']);
    //postalCode = PostalCode.fromJson(json['postalCode']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name.toJson();
    data['tld'] = tld;
    data['cca2'] = cca2;
    data['ccn3'] = ccn3;
    data['cca3'] = cca3;
    data['independent'] = independent;
    data['status'] = status;
    data['unMember'] = unMember;
    data['currencies'] = currencies?.toJson();
    data['idd'] = idd.toJson();
    data['capital'] = capital;
    data['altSpellings'] = altSpellings;
    data['region'] = region;
    data['subregion'] = subregion;
    data['languages'] = languages?.toJson();
    //data['translations'] = translations.toJson();
    data['latlng'] = latlng;
    data['landlocked'] = landlocked;
    data['area'] = area;
    data['demonyms'] = demonyms?.toJson();
    data['flag'] = flag;
    data['maps'] = maps.toJson();
    data['population'] = population;
    data['car'] = car.toJson();
    data['timezones'] = timezones;
    data['continents'] = continents;
    data['flags'] = flags.toJson();
    data['coatOfArms'] = coatOfArms.toJson();
    data['startOfWeek'] = startOfWeek;
    //data['capitalInfo'] = capitalInfo.toJson();
    //data['postalCode'] = postalCode.toJson();
    return data;
  }
}

class Name {
  Name({
    required this.common,
    required this.official,
    //required this.nativeName,
  });
  late final String common;
  late final String official;
  //late final NativeName nativeName;

  Name.fromJson(Map<String, dynamic> json) {
    common = json['common'];
    official = json['official'];
    //nativeName = NativeName.fromJson(json['nativeName']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['common'] = common;
    data['official'] = official;
    //data['nativeName'] = nativeName.toJson();
    return data;
  }
}

// class NativeName {
//   NativeName({
//     required this.fra,
//   });
//   late final Fra fra;

//   NativeName.fromJson(Map<String, dynamic> json) {
//     fra = Fra.fromJson(json['fra']);
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['fra'] = fra.toJson();
//     return data;
//   }
// }

class Fra {
  Fra({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Fra.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Currencies {
  Currencies({
    required this.xpfModel,
  });
  late final XPFModel xpfModel;

  Currencies.fromJson(Map<String, dynamic> json) {
    xpfModel = XPFModel.fromJson(json[json.keys.first]);
  }

  Map<String, dynamic> toJson() {
    return {'XPF': xpfModel.toJson()};
  }
}

class XPFModel {
  XPFModel({
    required this.name,
    required this.symbol,
  });
  late final String name;
  late final String symbol;

  XPFModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    symbol = json['symbol'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['symbol'] = symbol;
    return data;
  }
}

class Idd {
  Idd({
    required this.root,
    required this.suffixes,
  });
  late final String root;
  late final List<String> suffixes;

  Idd.fromJson(Map<String, dynamic> json) {
    root = json['root'] ?? '';
    suffixes = List.castFrom<dynamic, String>(json['suffixes'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['root'] = root;
    data['suffixes'] = suffixes;
    return data;
  }
}

class Languages {
  Languages({
    required this.fra,
  });
  late final String fra;

  Languages.fromJson(Map<String, dynamic> json) {
    fra = json[json.keys.first];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fra'] = fra;
    return data;
  }
}

// class Translations {
//   Translations({
//     required this.ara,
//     required this.bre,
//     required this.ces,
//     required this.cym,
//     required this.deu,
//     required this.est,
//     required this.fin,
//     required this.fra,
//     required this.hrv,
//     required this.hun,
//     required this.ita,
//     required this.jpn,
//     required this.kor,
//     required this.nld,
//     required this.per,
//     required this.pol,
//     required this.por,
//     required this.rus,
//     required this.slk,
//     required this.spa,
//     required this.srp,
//     required this.swe,
//     required this.tur,
//     required this.urd,
//     required this.zho,
//   });
//   late final Ara ara;
//   late final Bre bre;
//   late final Ces ces;
//   late final Cym cym;
//   late final Deu deu;
//   late final Est est;
//   late final Fin fin;
//   late final Fra fra;
//   late final Hrv hrv;
//   late final Hun hun;
//   late final Ita ita;
//   late final Jpn jpn;
//   late final Kor kor;
//   late final Nld nld;
//   late final Per per;
//   late final Pol pol;
//   late final Por por;
//   late final Rus rus;
//   late final Slk slk;
//   late final Spa spa;
//   late final Srp srp;
//   late final Swe swe;
//   late final Tur tur;
//   late final Urd urd;
//   late final Zho zho;

//   Translations.fromJson(Map<String, dynamic> json) {
//     ara = Ara.fromJson(json['ara']);
//     bre = Bre.fromJson(json['bre']);
//     ces = Ces.fromJson(json['ces']);
//     cym = Cym.fromJson(json['cym']);
//     deu = Deu.fromJson(json['deu']);
//     est = Est.fromJson(json['est']);
//     fin = Fin.fromJson(json['fin']);
//     fra = Fra.fromJson(json['fra']);
//     hrv = json['hrv'] != null ? Hrv.fromJson(json['hrv']) :Hrv ;
//     hun = Hun.fromJson(json['hun']);
//     ita = Ita.fromJson(json['ita']);
//     jpn = Jpn.fromJson(json['jpn']);
//     kor = Kor.fromJson(json['kor']);
//     nld = Nld.fromJson(json['nld']);
//     per = Per.fromJson(json['per']);
//     pol = Pol.fromJson(json['pol']);
//     por = Por.fromJson(json['por']);
//     rus = Rus.fromJson(json['rus']);
//     slk = Slk.fromJson(json['slk']);
//     spa = Spa.fromJson(json['spa']);
//     srp = Srp.fromJson(json['srp']);
//     swe = Swe.fromJson(json['swe']);
//     tur = Tur.fromJson(json['tur']);
//     urd = Urd.fromJson(json['urd']);
//     zho = json['zho'] != null
//         ? Zho.fromJson(json['zho'])
//         : Zho(official: '', common: '');
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['ara'] = ara.toJson();
//     data['bre'] = bre.toJson();
//     data['ces'] = ces.toJson();
//     data['cym'] = cym.toJson();
//     data['deu'] = deu.toJson();
//     data['est'] = est.toJson();
//     data['fin'] = fin.toJson();
//     data['fra'] = fra.toJson();
//     data['hrv'] = hrv.toJson();
//     data['hun'] = hun.toJson();
//     data['ita'] = ita.toJson();
//     data['jpn'] = jpn.toJson();
//     data['kor'] = kor.toJson();
//     data['nld'] = nld.toJson();
//     data['per'] = per.toJson();
//     data['pol'] = pol.toJson();
//     data['por'] = por.toJson();
//     data['rus'] = rus.toJson();
//     data['slk'] = slk.toJson();
//     data['spa'] = spa.toJson();
//     data['srp'] = srp.toJson();
//     data['swe'] = swe.toJson();
//     data['tur'] = tur.toJson();
//     data['urd'] = urd.toJson();
//     data['zho'] = zho.toJson();
//     return data;
//   }
// }

class Ara {
  Ara({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Ara.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Bre {
  Bre({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Bre.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Ces {
  Ces({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Ces.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Cym {
  Cym({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Cym.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Deu {
  Deu({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Deu.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Est {
  Est({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Est.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Fin {
  Fin({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Fin.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Hrv {
  Hrv({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Hrv.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Hun {
  Hun({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Hun.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Ita {
  Ita({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Ita.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Jpn {
  Jpn({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Jpn.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Kor {
  Kor({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Kor.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Nld {
  Nld({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Nld.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Per {
  Per({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Per.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Pol {
  Pol({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Pol.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Por {
  Por({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Por.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Rus {
  Rus({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Rus.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Slk {
  Slk({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Slk.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Spa {
  Spa({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Spa.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Srp {
  Srp({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Srp.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Swe {
  Swe({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Swe.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Tur {
  Tur({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Tur.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Urd {
  Urd({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Urd.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Zho {
  Zho({
    required this.official,
    required this.common,
  });
  late final String official;
  late final String common;

  Zho.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Demonyms {
  Demonyms({
    required this.eng,
  });
  late final Eng eng;

  Demonyms.fromJson(Map<String, dynamic> json) {
    eng = Eng.fromJson(json['eng']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['eng'] = eng.toJson();
    return data;
  }
}

class Eng {
  Eng({
    required this.f,
    required this.m,
  });
  late final String f;
  late final String m;

  Eng.fromJson(Map<String, dynamic> json) {
    f = json['f'];
    m = json['m'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['f'] = f;
    data['m'] = m;
    return data;
  }
}

class Maps {
  Maps({
    required this.googleMaps,
    required this.openStreetMaps,
  });
  late final String googleMaps;
  late final String openStreetMaps;

  Maps.fromJson(Map<String, dynamic> json) {
    googleMaps = json['googleMaps'];
    openStreetMaps = json['openStreetMaps'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['googleMaps'] = googleMaps;
    data['openStreetMaps'] = openStreetMaps;
    return data;
  }
}

class Car {
  Car({
    required this.signs,
    required this.side,
  });
  late final List<String> signs;
  late final String side;

  Car.fromJson(Map<String, dynamic> json) {
    signs = List.castFrom<dynamic, String>(json['signs'] ?? []);
    side = json['side'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['signs'] = signs;
    data['side'] = side;
    return data;
  }
}

class Flags {
  Flags({
    required this.png,
    required this.svg,
  });
  late final String png;
  late final String svg;

  Flags.fromJson(Map<String, dynamic> json) {
    png = json['png'];
    svg = json['svg'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['png'] = png;
    data['svg'] = svg;
    return data;
  }
}

class CoatOfArms {
  CoatOfArms();

  CoatOfArms.fromJson(Map json);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    return data;
  }
}

class CapitalInfo {
  CapitalInfo({
    required this.latlng,
  });
  late final List<double> latlng;

  CapitalInfo.fromJson(Map<String, dynamic> json) {
    latlng = List.castFrom<dynamic, double>(json['latlng']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['latlng'] = latlng;
    return data;
  }
}

// class PostalCode {
//   PostalCode({
//     required this.format,
//     required this.regex,
//   });
//   late final String format;
//   late final String regex;

//   PostalCode.fromJson(Map<String, dynamic> json) {
//     format = json['format'];
//     regex = json['regex'];
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['format'] = format;
//     data['regex'] = regex;
//     return data;
//   }
// }
