import '../models/chat_message.dart';
import '../models/dating_profile.dart';

const mockProfiles = <DatingProfile>[
  DatingProfile(
    id: 'profile-1',
    name: 'Salsabila',
    age: 22,
    city: 'Bandung',
    bio: 'Pencinta kopi, buku, dan jalan sore.',
    imageUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
    distanceKm: 4,
    interests: ['Kopi', 'Buku', 'Jalan sore'],
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'profile-2',
    name: 'Nabila',
    age: 25,
    city: 'Jakarta',
    bio: 'Senang mencoba tempat makan baru.',
    imageUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
    distanceKm: 9,
    interests: ['Kuliner', 'Musik', 'Traveling'],
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'profile-3',
    name: 'Kirana',
    age: 29,
    city: 'Yogyakarta',
    bio: 'Tim pantai saat liburan, tim rumah saat akhir pekan.',
    imageUrl:
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=900',
    distanceKm: 16,
    interests: ['Pantai', 'Film', 'Fotografi'],
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'profile-4',
    name: 'Alya',
    age: 27,
    city: 'Bandung',
    bio: 'Mencari teman berbagi cerita dan playlist.',
    imageUrl:
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=900',
    distanceKm: 7,
    interests: ['Musik', 'Lari', 'Seni'],
    mutualMatch: true,
  ),
];

const mockMessagesByProfile = <String, List<ChatMessage>>{
  'profile-2': [
    ChatMessage(
      text: 'Hai! Ada rekomendasi tempat makan enak?',
      isMine: false,
      timeLabel: '10.12',
    ),
    ChatMessage(
      text: 'Ada, nanti aku kirim ya 😊',
      isMine: true,
      timeLabel: '10.14',
    ),
  ],
  'profile-4': [
    ChatMessage(
      text: 'Hai, senang bisa kenalan!',
      isMine: false,
      timeLabel: 'Kemarin',
    ),
  ],
};
