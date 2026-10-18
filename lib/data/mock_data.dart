import '../models/chat_message.dart';
import '../models/dating_profile.dart';

const mockCurrentProfile = DatingProfile(
  id: 'current-profile',
  name: 'Alya',
  age: 26,
  city: 'Jakarta',
  bio: 'Pencinta kopi, musik, dan cerita baru.',
  imageUrl:
      'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=900',
  distanceKm: 0,
  interests: ['Kopi', 'Musik', 'Membaca'],
  mutualMatch: false,
);

const mockProfiles = <DatingProfile>[
  DatingProfile(
    id: 'profile-1',
    name: 'Nadia',
    age: 27,
    city: 'Bandung',
    bio: 'Pencinta kopi, buku, perjalanan, dan menikmati senja.',
    imageUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
    distanceKm: 12,
    interests: ['Coffee', 'Books', 'Travel', 'Sunset'],
    mutualMatch: true,
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
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'profile-5',
    name: 'Dinda',
    age: 32,
    city: 'Semarang',
    bio: 'Senang memasak dan mengunjungi tempat baru.',
    imageUrl:
        'https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43?w=900',
    distanceKm: 35,
    interests: ['Memasak', 'Film', 'Traveling'],
    mutualMatch: false,
  ),
];

const mockIncomingLikes = <DatingProfile>[
  DatingProfile(
    id: 'incoming-1',
    name: 'Sofia',
    age: 27,
    city: 'Jakarta',
    bio: '',
    imageUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
    distanceKm: 12,
    interests: [],
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'incoming-2',
    name: 'Mira',
    age: 25,
    city: 'Jakarta',
    bio: '',
    imageUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
    distanceKm: 9,
    interests: [],
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'incoming-3',
    name: 'Tara',
    age: 29,
    city: 'Jakarta',
    bio: '',
    imageUrl:
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=900',
    distanceKm: 16,
    interests: [],
    mutualMatch: false,
  ),
  DatingProfile(
    id: 'incoming-4',
    name: 'Dina',
    age: 32,
    city: 'Jakarta',
    bio: '',
    imageUrl:
        'https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43?w=900',
    distanceKm: 35,
    interests: [],
    mutualMatch: false,
  ),
];

const mockMessagesByProfile = <String, List<ChatMessage>>{
  'profile-1': [
    ChatMessage(
      text: 'Hai! Senang bisa kenalan 😊',
      isMine: false,
      timeLabel: '09:12',
    ),
    ChatMessage(
      text: 'Hai Nadia! Aku juga senang 😊',
      isMine: true,
      timeLabel: '09:13',
    ),
    ChatMessage(text: 'Kamu lagi apa?', isMine: false, timeLabel: '09:14'),
    ChatMessage(
      text: 'Baru selesai ngopi. Kamu?',
      isMine: true,
      timeLabel: '09:15',
    ),
    ChatMessage(
      text: 'Aku baru bikin kopi juga ☕',
      isMine: false,
      timeLabel: '09:16',
    ),
    ChatMessage(
      text: 'Wah, kapan-kapan ngopi bareng yuk!',
      isMine: true,
      timeLabel: '09:17',
    ),
  ],
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
