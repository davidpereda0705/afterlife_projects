import 'package:afterlife_projects/models/club_model.dart';

const List<Club> kClubs = [
  // ─── MADRID ───────────────────────────────────────────────────────────────
  Club(
    id: 'mad_fabrik',
    name: 'Fabrik',
    city: 'Madrid',
    address: 'Av. de la Industria, 82, Humanes de Madrid',
    shortDescription: 'El templo del techno en Madrid. Aforo para 5.000 personas.',
    description:
        'Fabrik es el club de referencia de la escena electrónica en Madrid y uno de los más grandes de España. '
        'Con una pista principal de más de 3.000 m² y un sonido Funktion-One de primera clase, '
        'atrae a los mejores DJs internacionales de techno, techno industrial y electrónica de vanguardia. '
        'Abre los viernes y sábados de madrugada, con sesiones que duran hasta el domingo por la tarde.',
    musicGenres: ['Techno', 'Industrial', 'EBM'],
    ticketsUrl: 'https://www.fabricmadrid.es/entradas',
    websiteUrl: 'https://www.fabricmadrid.es',
    instagramUrl: 'https://www.instagram.com/fabrik_madrid',
    schedule: 'Vie-Sáb: 00:00 – 14:00',
    priceRange: '15 € – 25 €',
    capacity: 5000,
    latitude: 40.3105,
    longitude: -3.8510,
    tags: ['Gran aforo', 'Sound system', 'DJ internacionales'],
    gradientKey: 'purple',
  ),
  Club(
    id: 'mad_mondo',
    name: 'Mondo Disko',
    city: 'Madrid',
    address: 'C. de Barceló, 11, Madrid',
    shortDescription: 'Cultura de club de Madrid desde los 90. House, disco y pop electrónico.',
    description:
        'Mondo Disko es una institución en la noche madrileña. Con décadas de historia, este club de tamaño medio '
        'destaca por su programación ecléctica que mezcla house, disco, pop electrónico y música de los 80-90. '
        'Su ambiente íntimo y su decoración retro-futurista lo convierten en una experiencia única. '
        'Perfecto para bailar en una pista con energia sin perder la proximidad con el DJ.',
    musicGenres: ['House', 'Disco', 'Pop Electrónico'],
    ticketsUrl: 'https://www.mondodisko.com',
    websiteUrl: 'https://www.mondodisko.com',
    instagramUrl: 'https://www.instagram.com/mondodisko',
    schedule: 'Jue-Sáb: 23:30 – 06:00',
    priceRange: '10 € – 18 €',
    capacity: 600,
    latitude: 40.4275,
    longitude: -3.6997,
    tags: ['Histórico', 'Ambiente íntimo', 'Años 90'],
    gradientKey: 'pink',
  ),
  Club(
    id: 'mad_kapital',
    name: 'Kapital',
    city: 'Madrid',
    address: 'C. de Atocha, 125, Madrid',
    shortDescription: '7 plantas de música en un teatro reconvertido. El más grande de Madrid.',
    description:
        'Kapital es uno de los clubs más icónicos y visitados de Madrid, situado en un espectacular teatro reconvertido. '
        'Sus 7 plantas ofrecen diferentes ambientes musicales: desde reggaeton y comercial hasta hip-hop, R&B y electrónica. '
        'Cada planta tiene su propio bar y pista de baile, lo que permite moverse entre estilos durante la noche. '
        'La terraza en la última planta es uno de los puntos más deseados en verano.',
    musicGenres: ['Comercial', 'Reggaeton', 'Hip-Hop', 'R&B'],
    ticketsUrl: 'https://grupo-kapital.com/entrada',
    websiteUrl: 'https://grupo-kapital.com',
    instagramUrl: 'https://www.instagram.com/grupokaplital',
    schedule: 'Jue-Sáb: 23:30 – 06:30',
    priceRange: '12 € – 20 €',
    capacity: 3000,
    latitude: 40.4070,
    longitude: -3.6918,
    tags: ['Teatro reconvertido', '7 plantas', 'Multi-estilo'],
    gradientKey: 'cyan',
  ),

  // ─── BARCELONA ────────────────────────────────────────────────────────────
  Club(
    id: 'bcn_razzmatazz',
    name: 'Razzmatazz',
    city: 'Barcelona',
    address: 'C/ dels Almogàvers, 122, Barcelona',
    shortDescription: '5 salas, 5 estilos. La meca del ocio nocturno barcelonés.',
    description:
        'Razzmatazz es el club de referencia de Barcelona y uno de los más importantes de Europa. '
        'Con 5 salas de música independientes —The Loft, Lolita, Rex Room, Razz Club y Pop Bar— '
        'cada noche ofrece estilos que van desde la electrónica más experimental hasta el indie, pop y rock. '
        'Ha acogido actuaciones de artistas como Daft Punk, The Chemical Brothers, Arctic Monkeys y muchos más. '
        'También funciona como sala de conciertos con una programación envidiable.',
    musicGenres: ['Electrónica', 'Indie', 'Pop', 'Rock'],
    ticketsUrl: 'https://www.razzmatazz.es/entradas',
    websiteUrl: 'https://www.razzmatazz.es',
    instagramUrl: 'https://www.instagram.com/razzmatazzbcn',
    schedule: 'Jue-Sáb: 23:00 – 06:00',
    priceRange: '12 € – 25 €',
    capacity: 4500,
    latitude: 41.3994,
    longitude: 2.1883,
    tags: ['5 salas', 'Conciertos', 'Icónico'],
    gradientKey: 'orange',
  ),
  Club(
    id: 'bcn_nitsa',
    name: 'Nitsa Club',
    city: 'Barcelona',
    address: 'C/ dels Almogàvers, 122, Barcelona (dentro de Razzmatazz)',
    shortDescription: 'La sala electrónica más respetada de Barcelona. Techno y house de altura.',
    description:
        'Nitsa Club funciona dentro del espacio de Razzmatazz como la sala electrónica más valorada de Barcelona. '
        'Con una programación cuidadísima, trae a los mejores DJs del panorama techno y house internacional. '
        'Su sonido y su atmósfera oscura y minimalista la convierten en un lugar de culto para los amantes '
        'de la electrónica seria. Nitsa edita también su propia revista y ha sido pionera en la cultura de club española.',
    musicGenres: ['Techno', 'House', 'Electrónica'],
    ticketsUrl: 'https://www.razzmatazz.es/nitsa',
    websiteUrl: 'https://www.nitsaclub.com',
    instagramUrl: 'https://www.instagram.com/nitsaclub',
    schedule: 'Vie-Sáb: 00:00 – 06:00',
    priceRange: '15 € – 22 €',
    capacity: 1000,
    latitude: 41.3994,
    longitude: 2.1883,
    tags: ['Electrónica seria', 'Curada', 'DJ top'],
    gradientKey: 'purple',
  ),
  Club(
    id: 'bcn_sala_apolo',
    name: 'Sala Apolo',
    city: 'Barcelona',
    address: 'C/ Nou de la Rambla, 113, Barcelona',
    shortDescription: 'Teatro modernista de 1943 convertido en sala de conciertos y club.',
    description:
        'La Sala Apolo es uno de los espacios más emblemáticos del Paralelo barcelonés. Construida en 1943, '
        'conserva toda la magia y arquitectura de un teatro de varietés. Hoy acoge conciertos de artistas '
        'internacionales y noches de club bajo el sello Nasty Mondays (los lunes) y Crappy Tuesdays, '
        'además de sesiones de funk, soul, indie y electrónica. Su ambiente es inigualable.',
    musicGenres: ['Funk', 'Soul', 'Indie', 'Electrónica'],
    ticketsUrl: 'https://www.sala-apolo.com/entradas',
    websiteUrl: 'https://www.sala-apolo.com',
    instagramUrl: 'https://www.instagram.com/sala_apolo',
    schedule: 'Lun y Mar (Nights), Vie-Sáb (Conciertos)',
    priceRange: '10 € – 20 €',
    capacity: 1200,
    latitude: 41.3730,
    longitude: 2.1662,
    tags: ['Histórico', 'Teatro', 'Conciertos'],
    gradientKey: 'pink',
  ),

  // ─── IBIZA ────────────────────────────────────────────────────────────────
  Club(
    id: 'ibz_pacha',
    name: 'Pacha Ibiza',
    city: 'Ibiza',
    address: 'Av. 8 d\'Agosto, s/n, Ibiza',
    shortDescription: 'La discoteca más famosa del mundo. Lujo y hedonismo en estado puro.',
    description:
        'Pacha Ibiza es sinónimo de glamour, hedonismo y música electrónica de primer nivel. '
        'Fundada en 1973, es una de las discotecas más antiguas e icónicas del planeta. '
        'Sus dos cerezas son reconocidas mundialmente. Con varias salas, terraza y una decoración exuberante, '
        'acoge a los DJs más famosos del circuito electrónico global: David Guetta, Kygo, Calvin Harris y muchos más. '
        'Una experiencia que hay que vivir al menos una vez en la vida.',
    musicGenres: ['House', 'EDM', 'Commercial Electronic'],
    ticketsUrl: 'https://www.pacha.com/ibiza/entradas',
    websiteUrl: 'https://www.pacha.com/ibiza',
    instagramUrl: 'https://www.instagram.com/pachaworldwide',
    schedule: 'Abr-Oct: Diario 23:30 – 06:00',
    priceRange: '40 € – 80 €',
    capacity: 3000,
    latitude: 38.9069,
    longitude: 1.4325,
    tags: ['Legendario', 'VIP', 'Temporada verano'],
    gradientKey: 'orange',
  ),
  Club(
    id: 'ibz_amnesia',
    name: 'Amnesia Ibiza',
    city: 'Ibiza',
    address: 'Carretera Ibiza a San Antonio, km 5, Ibiza',
    shortDescription: 'Cuna de la cultura de foam parties y el sonido balear. Imprescindible.',
    description:
        'Amnesia es una de las discotecas más históricas e influyentes de Ibiza. Famosa por inventar las foam parties '
        'y por su espectacular apertura al exterior, mezcla pistas indoor y una zona terrace única. '
        'Ha sido la casa de DJs legendarios como Marco Carola (Music On) y continúa siendo un referente '
        'del house y techno ibicenco. Su arquitectura y ambiente la hacen especial incluso entre los clubbers más exigentes.',
    musicGenres: ['House', 'Techno', 'Balearic'],
    ticketsUrl: 'https://www.amnesia.es/entradas',
    websiteUrl: 'https://www.amnesia.es',
    instagramUrl: 'https://www.instagram.com/amnesia_ibiza',
    schedule: 'May-Oct: Jue-Dom 23:00 – 06:00',
    priceRange: '30 € – 60 €',
    capacity: 4000,
    latitude: 38.9430,
    longitude: 1.3905,
    tags: ['Foam parties', 'Terrace', 'Historia'],
    gradientKey: 'cyan',
  ),
  Club(
    id: 'ibz_dc10',
    name: 'DC-10',
    city: 'Ibiza',
    address: 'Carretera de Ses Salines, Ibiza',
    shortDescription: 'Afterhours de culto. El lugar donde el techno más underground se vive.',
    description:
        'DC-10 es el club underground por excelencia de Ibiza. Situado junto al aeropuerto, '
        'es famoso por su fiesta Circoloco los lunes y por sus sesiones de afterhours '
        'donde el techno, house underground y la música más oscura son los protagonistas. '
        'Sin pretensiones de lujo, su ambiente raw y auténtico lo ha convertido en un lugar de culto '
        'para los verdaderos amantes de la cultura de club. Dress code: sin dress code.',
    musicGenres: ['Techno', 'House Underground', 'Deep'],
    ticketsUrl: 'https://www.dc-10.es',
    websiteUrl: 'https://www.dc-10.es',
    instagramUrl: 'https://www.instagram.com/dc10ibiza',
    schedule: 'Lun (Circoloco), Sáb (Afterhours)',
    priceRange: '20 € – 35 €',
    capacity: 1500,
    latitude: 38.8760,
    longitude: 1.3732,
    tags: ['Underground', 'Afterhours', 'Culto'],
    gradientKey: 'purple',
  ),

  // ─── VALENCIA ─────────────────────────────────────────────────────────────
  Club(
    id: 'vlc_akuarela',
    name: 'Akuarela Playa',
    city: 'Valencia',
    address: 'Playa de Pinedo, Valencia',
    shortDescription: 'El club de playa más grande de España. House y electrónica junto al mar.',
    description:
        'Akuarela Playa es uno de los clubes de playa más grandes y espectaculares de España. '
        'Situado directamente sobre la arena de la playa de Pinedo, combina piscinas, '
        'zona chill-out y una pista de baile con sonido de primer nivel. '
        'Su programación de house, tech-house y electrónica atrae a DJs internacionales '
        'durante toda la temporada de verano. El contraste entre el mar, las palmeras y la música hace la experiencia única.',
    musicGenres: ['House', 'Tech-House', 'Electrónica'],
    ticketsUrl: 'https://www.akuarela.com/entradas',
    websiteUrl: 'https://www.akuarela.com',
    instagramUrl: 'https://www.instagram.com/akuarelaplayadisco',
    schedule: 'Jun-Sep: Vie-Dom 23:30 – 07:00',
    priceRange: '15 € – 30 €',
    capacity: 6000,
    latitude: 39.4197,
    longitude: -0.3330,
    tags: ['Club de playa', 'Piscina', 'Temporada verano'],
    gradientKey: 'cyan',
  ),

  // ─── BILBAO ───────────────────────────────────────────────────────────────
  Club(
    id: 'bil_fever',
    name: 'Fever Bilbao',
    city: 'Bilbao',
    address: 'C/ Licenciado Poza, 19, Bilbao',
    shortDescription: 'El referente de la noche bilbaína. Comercial y reggaeton de calidad.',
    description:
        'Fever es el club más conocido de Bilbao, con varias salas que cubren distintos estilos '
        'musicales durante la noche. Desde reggaeton y música latina hasta comercial española e internacional, '
        'es el punto de encuentro de la juventud bilbaína durante el fin de semana. '
        'Su ubicación central en el Casco Viejo lo hace fácilmente accesible y lo convierte en '
        'parada habitual de cualquier noche en Bilbao.',
    musicGenres: ['Reggaeton', 'Comercial', 'Latino'],
    ticketsUrl: 'https://www.feverbilbao.com',
    websiteUrl: 'https://www.feverbilbao.com',
    instagramUrl: 'https://www.instagram.com/feverbilbao',
    schedule: 'Vie-Sáb: 00:00 – 05:30',
    priceRange: '8 € – 15 €',
    capacity: 800,
    latitude: 43.2610,
    longitude: -2.9248,
    tags: ['Casco Viejo', 'Multi-sala', 'Accesible'],
    gradientKey: 'pink',
  ),
];

List<String> get kAllCities {
  final cities = kClubs.map((c) => c.city).toSet().toList();
  cities.sort();
  return cities;
}
