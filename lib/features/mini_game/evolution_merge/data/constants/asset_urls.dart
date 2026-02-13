/// Asset URLs for Evolution Merge game
class EvolutionAssetUrls {
  static const String baseUrl = 'https://d2oir5eh8rty2e.cloudfront.net/assets';

  // Evolution creature images
  static const Map<String, String> images = {
    'evo_ooze': '$baseUrl/images/07f3af6c-377a-401f-8365-b8c6b4ff5894.webp',
    'evo_cell': '$baseUrl/images/066e5b56-e95f-495f-9eb0-ea96818fcdd6.webp',
    'evo_bacteria': '$baseUrl/images/1129cdfb-323f-4104-8f94-561ee43feeb1.webp',
    'evo_jellyfish':
        '$baseUrl/images/00e6f55c-48c3-4ae6-b985-81e143c4baf3.webp',
    'evo_fish': '$baseUrl/images/35ca2e81-1a1c-49ce-8930-a59f316ac946.webp',
    'evo_amphibian':
        '$baseUrl/images/d5bb29ea-cd74-4565-875e-5a2ca1ca8590.webp',
    'evo_reptile': '$baseUrl/images/d3437ecb-fbc1-41c9-9ec2-48493184533f.webp',
    'evo_mammal': '$baseUrl/images/cfb4d4c0-816c-4861-bcc5-19ba41a4488a.webp',
    'evo_primate': '$baseUrl/images/44893a9d-a696-4f60-ad3f-bdac16839c3e.webp',
    'evo_caveman': '$baseUrl/images/17b12b10-57a3-43aa-b1ff-ad39b2c6d0db.webp',
    'evo_human': '$baseUrl/images/a1bfcbbf-3fdf-4d7e-929e-3ec55e7e7df5.webp',
    'background_primordial':
        '$baseUrl/images/2c849dab-0df2-4a29-b564-d54be494f1e5.webp',
  };

  // Sound effects
  static const Map<String, String> sounds = {
    'sound_drop':
        '$baseUrl/sounds/effect/a3162c99-7625-45d5-b695-997de57277b6.mp3',
    'sound_merge':
        '$baseUrl/sounds/effect/98477e59-bad3-4805-958a-c1ee68598627.mp3',
    'sound_evolve':
        '$baseUrl/sounds/effect/dc83f944-e54b-49ad-b510-44af76a2d3c8.mp3',
    'sound_gameover':
        '$baseUrl/sounds/effect/6a64ca3b-0ebc-4c3c-ab0e-8d1046edb0ea.mp3',
  };

  // Background music
  static const Map<String, String> music = {
    'music_evolution':
        '$baseUrl/sounds/music/5f8d7005-fc59-4e85-bf16-1c7fead3615e.mp3',
    'music_evolution_retro':
        '$baseUrl/sounds/music/aa39c269-16f4-4d0e-9968-81b3dc114618.mp3',
  };

  static String? getImageUrl(String assetId) => images[assetId];
  static String? getSoundUrl(String assetId) => sounds[assetId];
  static String? getMusicUrl(String assetId) => music[assetId];
}
