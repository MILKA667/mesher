// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts
    with TableInfo<$ContactsTable, ContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<Uint8List> publicKey = GeneratedColumn<Uint8List>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _signalLevelMeta = const VerificationMeta(
    'signalLevel',
  );
  @override
  late final GeneratedColumn<int> signalLevel = GeneratedColumn<int>(
    'signal_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<int> distanceMeters = GeneratedColumn<int>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nodeId,
    publicKey,
    mode,
    signalLevel,
    isOnline,
    distanceMeters,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('signal_level')) {
      context.handle(
        _signalLevelMeta,
        signalLevel.isAcceptableOrUnknown(
          data['signal_level']!,
          _signalLevelMeta,
        ),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      nodeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}node_id'],
          )!,
      publicKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}public_key'],
          )!,
      mode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}mode'],
          )!,
      signalLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}signal_level'],
          )!,
      isOnline:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_online'],
          )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_meters'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class ContactRow extends DataClass implements Insertable<ContactRow> {
  final String id;
  final String name;
  final String nodeId;
  final Uint8List publicKey;
  final int mode;
  final int signalLevel;
  final bool isOnline;
  final int? distanceMeters;
  final DateTime createdAt;
  const ContactRow({
    required this.id,
    required this.name,
    required this.nodeId,
    required this.publicKey,
    required this.mode,
    required this.signalLevel,
    required this.isOnline,
    this.distanceMeters,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['node_id'] = Variable<String>(nodeId);
    map['public_key'] = Variable<Uint8List>(publicKey);
    map['mode'] = Variable<int>(mode);
    map['signal_level'] = Variable<int>(signalLevel);
    map['is_online'] = Variable<bool>(isOnline);
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<int>(distanceMeters);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      name: Value(name),
      nodeId: Value(nodeId),
      publicKey: Value(publicKey),
      mode: Value(mode),
      signalLevel: Value(signalLevel),
      isOnline: Value(isOnline),
      distanceMeters:
          distanceMeters == null && nullToAbsent
              ? const Value.absent()
              : Value(distanceMeters),
      createdAt: Value(createdAt),
    );
  }

  factory ContactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      publicKey: serializer.fromJson<Uint8List>(json['publicKey']),
      mode: serializer.fromJson<int>(json['mode']),
      signalLevel: serializer.fromJson<int>(json['signalLevel']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      distanceMeters: serializer.fromJson<int?>(json['distanceMeters']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nodeId': serializer.toJson<String>(nodeId),
      'publicKey': serializer.toJson<Uint8List>(publicKey),
      'mode': serializer.toJson<int>(mode),
      'signalLevel': serializer.toJson<int>(signalLevel),
      'isOnline': serializer.toJson<bool>(isOnline),
      'distanceMeters': serializer.toJson<int?>(distanceMeters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContactRow copyWith({
    String? id,
    String? name,
    String? nodeId,
    Uint8List? publicKey,
    int? mode,
    int? signalLevel,
    bool? isOnline,
    Value<int?> distanceMeters = const Value.absent(),
    DateTime? createdAt,
  }) => ContactRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nodeId: nodeId ?? this.nodeId,
    publicKey: publicKey ?? this.publicKey,
    mode: mode ?? this.mode,
    signalLevel: signalLevel ?? this.signalLevel,
    isOnline: isOnline ?? this.isOnline,
    distanceMeters:
        distanceMeters.present ? distanceMeters.value : this.distanceMeters,
    createdAt: createdAt ?? this.createdAt,
  );
  ContactRow copyWithCompanion(ContactsCompanion data) {
    return ContactRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      mode: data.mode.present ? data.mode.value : this.mode,
      signalLevel:
          data.signalLevel.present ? data.signalLevel.value : this.signalLevel,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      distanceMeters:
          data.distanceMeters.present
              ? data.distanceMeters.value
              : this.distanceMeters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nodeId: $nodeId, ')
          ..write('publicKey: $publicKey, ')
          ..write('mode: $mode, ')
          ..write('signalLevel: $signalLevel, ')
          ..write('isOnline: $isOnline, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nodeId,
    $driftBlobEquality.hash(publicKey),
    mode,
    signalLevel,
    isOnline,
    distanceMeters,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nodeId == this.nodeId &&
          $driftBlobEquality.equals(other.publicKey, this.publicKey) &&
          other.mode == this.mode &&
          other.signalLevel == this.signalLevel &&
          other.isOnline == this.isOnline &&
          other.distanceMeters == this.distanceMeters &&
          other.createdAt == this.createdAt);
}

class ContactsCompanion extends UpdateCompanion<ContactRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> nodeId;
  final Value<Uint8List> publicKey;
  final Value<int> mode;
  final Value<int> signalLevel;
  final Value<bool> isOnline;
  final Value<int?> distanceMeters;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.mode = const Value.absent(),
    this.signalLevel = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String name,
    required String nodeId,
    required Uint8List publicKey,
    this.mode = const Value.absent(),
    this.signalLevel = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nodeId = Value(nodeId),
       publicKey = Value(publicKey);
  static Insertable<ContactRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nodeId,
    Expression<Uint8List>? publicKey,
    Expression<int>? mode,
    Expression<int>? signalLevel,
    Expression<bool>? isOnline,
    Expression<int>? distanceMeters,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nodeId != null) 'node_id': nodeId,
      if (publicKey != null) 'public_key': publicKey,
      if (mode != null) 'mode': mode,
      if (signalLevel != null) 'signal_level': signalLevel,
      if (isOnline != null) 'is_online': isOnline,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? nodeId,
    Value<Uint8List>? publicKey,
    Value<int>? mode,
    Value<int>? signalLevel,
    Value<bool>? isOnline,
    Value<int?>? distanceMeters,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nodeId: nodeId ?? this.nodeId,
      publicKey: publicKey ?? this.publicKey,
      mode: mode ?? this.mode,
      signalLevel: signalLevel ?? this.signalLevel,
      isOnline: isOnline ?? this.isOnline,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<Uint8List>(publicKey.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (signalLevel.present) {
      map['signal_level'] = Variable<int>(signalLevel.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<int>(distanceMeters.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nodeId: $nodeId, ')
          ..write('publicKey: $publicKey, ')
          ..write('mode: $mode, ')
          ..write('signalLevel: $signalLevel, ')
          ..write('isOnline: $isOnline, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, ChatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTimeMeta = const VerificationMeta(
    'lastMessageTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageTime =
      GeneratedColumn<DateTime>(
        'last_message_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isGroupMeta = const VerificationMeta(
    'isGroup',
  );
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
    'is_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    displayName,
    lastMessage,
    lastMessageTime,
    unreadCount,
    isGroup,
    memberCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
        _lastMessageTimeMeta,
        lastMessageTime.isAcceptableOrUnknown(
          data['last_message_time']!,
          _lastMessageTimeMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      contactId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}contact_id'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      lastMessageTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_time'],
      ),
      unreadCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}unread_count'],
          )!,
      isGroup:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_group'],
          )!,
      memberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_count'],
      ),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class ChatRow extends DataClass implements Insertable<ChatRow> {
  final String id;
  final String contactId;
  final String displayName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final int? memberCount;
  const ChatRow({
    required this.id,
    required this.contactId,
    required this.displayName,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.isGroup,
    this.memberCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || memberCount != null) {
      map['member_count'] = Variable<int>(memberCount);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      displayName: Value(displayName),
      lastMessage:
          lastMessage == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMessage),
      lastMessageTime:
          lastMessageTime == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMessageTime),
      unreadCount: Value(unreadCount),
      isGroup: Value(isGroup),
      memberCount:
          memberCount == null && nullToAbsent
              ? const Value.absent()
              : Value(memberCount),
    );
  }

  factory ChatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRow(
      id: serializer.fromJson<String>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageTime: serializer.fromJson<DateTime?>(json['lastMessageTime']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      memberCount: serializer.fromJson<int?>(json['memberCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contactId': serializer.toJson<String>(contactId),
      'displayName': serializer.toJson<String>(displayName),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageTime': serializer.toJson<DateTime?>(lastMessageTime),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'isGroup': serializer.toJson<bool>(isGroup),
      'memberCount': serializer.toJson<int?>(memberCount),
    };
  }

  ChatRow copyWith({
    String? id,
    String? contactId,
    String? displayName,
    Value<String?> lastMessage = const Value.absent(),
    Value<DateTime?> lastMessageTime = const Value.absent(),
    int? unreadCount,
    bool? isGroup,
    Value<int?> memberCount = const Value.absent(),
  }) => ChatRow(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    displayName: displayName ?? this.displayName,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    lastMessageTime:
        lastMessageTime.present ? lastMessageTime.value : this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
    isGroup: isGroup ?? this.isGroup,
    memberCount: memberCount.present ? memberCount.value : this.memberCount,
  );
  ChatRow copyWithCompanion(ChatsCompanion data) {
    return ChatRow(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastMessageTime:
          data.lastMessageTime.present
              ? data.lastMessageTime.value
              : this.lastMessageTime,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      memberCount:
          data.memberCount.present ? data.memberCount.value : this.memberCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRow(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('displayName: $displayName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('isGroup: $isGroup, ')
          ..write('memberCount: $memberCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    displayName,
    lastMessage,
    lastMessageTime,
    unreadCount,
    isGroup,
    memberCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRow &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.displayName == this.displayName &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageTime == this.lastMessageTime &&
          other.unreadCount == this.unreadCount &&
          other.isGroup == this.isGroup &&
          other.memberCount == this.memberCount);
}

class ChatsCompanion extends UpdateCompanion<ChatRow> {
  final Value<String> id;
  final Value<String> contactId;
  final Value<String> displayName;
  final Value<String?> lastMessage;
  final Value<DateTime?> lastMessageTime;
  final Value<int> unreadCount;
  final Value<bool> isGroup;
  final Value<int?> memberCount;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    required String contactId,
    required String displayName,
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contactId = Value(contactId),
       displayName = Value(displayName);
  static Insertable<ChatRow> custom({
    Expression<String>? id,
    Expression<String>? contactId,
    Expression<String>? displayName,
    Expression<String>? lastMessage,
    Expression<DateTime>? lastMessageTime,
    Expression<int>? unreadCount,
    Expression<bool>? isGroup,
    Expression<int>? memberCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (displayName != null) 'display_name': displayName,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (isGroup != null) 'is_group': isGroup,
      if (memberCount != null) 'member_count': memberCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? contactId,
    Value<String>? displayName,
    Value<String?>? lastMessage,
    Value<DateTime?>? lastMessageTime,
    Value<int>? unreadCount,
    Value<bool>? isGroup,
    Value<int?>? memberCount,
    Value<int>? rowid,
  }) {
    return ChatsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      displayName: displayName ?? this.displayName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      memberCount: memberCount ?? this.memberCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('displayName: $displayName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('isGroup: $isGroup, ')
          ..write('memberCount: $memberCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOutgoingMeta = const VerificationMeta(
    'isOutgoing',
  );
  @override
  late final GeneratedColumn<bool> isOutgoing = GeneratedColumn<bool>(
    'is_outgoing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_outgoing" IN (0, 1))',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    kind,
    timestamp,
    isOutgoing,
    body,
    filePath,
    fileName,
    fileSizeBytes,
    durationSeconds,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_outgoing')) {
      context.handle(
        _isOutgoingMeta,
        isOutgoing.isAcceptableOrUnknown(data['is_outgoing']!, _isOutgoingMeta),
      );
    } else if (isInserting) {
      context.missing(_isOutgoingMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      kind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}kind'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      isOutgoing:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_outgoing'],
          )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final String id;
  final String chatId;
  final int kind;
  final DateTime timestamp;
  final bool isOutgoing;
  final String? body;
  final String? filePath;
  final String? fileName;
  final int? fileSizeBytes;
  final int? durationSeconds;
  final int status;
  const MessageRow({
    required this.id,
    required this.chatId,
    required this.kind,
    required this.timestamp,
    required this.isOutgoing,
    this.body,
    this.filePath,
    this.fileName,
    this.fileSizeBytes,
    this.durationSeconds,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['kind'] = Variable<int>(kind);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_outgoing'] = Variable<bool>(isOutgoing);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['status'] = Variable<int>(status);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      kind: Value(kind),
      timestamp: Value(timestamp),
      isOutgoing: Value(isOutgoing),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      filePath:
          filePath == null && nullToAbsent
              ? const Value.absent()
              : Value(filePath),
      fileName:
          fileName == null && nullToAbsent
              ? const Value.absent()
              : Value(fileName),
      fileSizeBytes:
          fileSizeBytes == null && nullToAbsent
              ? const Value.absent()
              : Value(fileSizeBytes),
      durationSeconds:
          durationSeconds == null && nullToAbsent
              ? const Value.absent()
              : Value(durationSeconds),
      status: Value(status),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      kind: serializer.fromJson<int>(json['kind']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isOutgoing: serializer.fromJson<bool>(json['isOutgoing']),
      body: serializer.fromJson<String?>(json['body']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'kind': serializer.toJson<int>(kind),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isOutgoing': serializer.toJson<bool>(isOutgoing),
      'body': serializer.toJson<String?>(body),
      'filePath': serializer.toJson<String?>(filePath),
      'fileName': serializer.toJson<String?>(fileName),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'status': serializer.toJson<int>(status),
    };
  }

  MessageRow copyWith({
    String? id,
    String? chatId,
    int? kind,
    DateTime? timestamp,
    bool? isOutgoing,
    Value<String?> body = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
    Value<int?> fileSizeBytes = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    int? status,
  }) => MessageRow(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    kind: kind ?? this.kind,
    timestamp: timestamp ?? this.timestamp,
    isOutgoing: isOutgoing ?? this.isOutgoing,
    body: body.present ? body.value : this.body,
    filePath: filePath.present ? filePath.value : this.filePath,
    fileName: fileName.present ? fileName.value : this.fileName,
    fileSizeBytes:
        fileSizeBytes.present ? fileSizeBytes.value : this.fileSizeBytes,
    durationSeconds:
        durationSeconds.present ? durationSeconds.value : this.durationSeconds,
    status: status ?? this.status,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      kind: data.kind.present ? data.kind.value : this.kind,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isOutgoing:
          data.isOutgoing.present ? data.isOutgoing.value : this.isOutgoing,
      body: data.body.present ? data.body.value : this.body,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSizeBytes:
          data.fileSizeBytes.present
              ? data.fileSizeBytes.value
              : this.fileSizeBytes,
      durationSeconds:
          data.durationSeconds.present
              ? data.durationSeconds.value
              : this.durationSeconds,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('kind: $kind, ')
          ..write('timestamp: $timestamp, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('body: $body, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    kind,
    timestamp,
    isOutgoing,
    body,
    filePath,
    fileName,
    fileSizeBytes,
    durationSeconds,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.kind == this.kind &&
          other.timestamp == this.timestamp &&
          other.isOutgoing == this.isOutgoing &&
          other.body == this.body &&
          other.filePath == this.filePath &&
          other.fileName == this.fileName &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.durationSeconds == this.durationSeconds &&
          other.status == this.status);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<int> kind;
  final Value<DateTime> timestamp;
  final Value<bool> isOutgoing;
  final Value<String?> body;
  final Value<String?> filePath;
  final Value<String?> fileName;
  final Value<int?> fileSizeBytes;
  final Value<int?> durationSeconds;
  final Value<int> status;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.kind = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.body = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String chatId,
    required int kind,
    required DateTime timestamp,
    required bool isOutgoing,
    this.body = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       kind = Value(kind),
       timestamp = Value(timestamp),
       isOutgoing = Value(isOutgoing);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<int>? kind,
    Expression<DateTime>? timestamp,
    Expression<bool>? isOutgoing,
    Expression<String>? body,
    Expression<String>? filePath,
    Expression<String>? fileName,
    Expression<int>? fileSizeBytes,
    Expression<int>? durationSeconds,
    Expression<int>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (kind != null) 'kind': kind,
      if (timestamp != null) 'timestamp': timestamp,
      if (isOutgoing != null) 'is_outgoing': isOutgoing,
      if (body != null) 'body': body,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<int>? kind,
    Value<DateTime>? timestamp,
    Value<bool>? isOutgoing,
    Value<String?>? body,
    Value<String?>? filePath,
    Value<String?>? fileName,
    Value<int?>? fileSizeBytes,
    Value<int?>? durationSeconds,
    Value<int>? status,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      kind: kind ?? this.kind,
      timestamp: timestamp ?? this.timestamp,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      body: body ?? this.body,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isOutgoing.present) {
      map['is_outgoing'] = Variable<bool>(isOutgoing.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('kind: $kind, ')
          ..write('timestamp: $timestamp, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('body: $body, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileTransfersTable extends FileTransfers
    with TableInfo<$FileTransfersTable, FileTransferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressPercentMeta = const VerificationMeta(
    'progressPercent',
  );
  @override
  late final GeneratedColumn<int> progressPercent = GeneratedColumn<int>(
    'progress_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _peerCountMeta = const VerificationMeta(
    'peerCount',
  );
  @override
  late final GeneratedColumn<int> peerCount = GeneratedColumn<int>(
    'peer_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speedBytesPerSecMeta = const VerificationMeta(
    'speedBytesPerSec',
  );
  @override
  late final GeneratedColumn<int> speedBytesPerSec = GeneratedColumn<int>(
    'speed_bytes_per_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _infoHashMeta = const VerificationMeta(
    'infoHash',
  );
  @override
  late final GeneratedColumn<String> infoHash = GeneratedColumn<String>(
    'info_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sizeBytes,
    direction,
    state,
    progressPercent,
    peerCount,
    speedBytesPerSec,
    infoHash,
    localPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileTransferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
        _progressPercentMeta,
        progressPercent.isAcceptableOrUnknown(
          data['progress_percent']!,
          _progressPercentMeta,
        ),
      );
    }
    if (data.containsKey('peer_count')) {
      context.handle(
        _peerCountMeta,
        peerCount.isAcceptableOrUnknown(data['peer_count']!, _peerCountMeta),
      );
    }
    if (data.containsKey('speed_bytes_per_sec')) {
      context.handle(
        _speedBytesPerSecMeta,
        speedBytesPerSec.isAcceptableOrUnknown(
          data['speed_bytes_per_sec']!,
          _speedBytesPerSecMeta,
        ),
      );
    }
    if (data.containsKey('info_hash')) {
      context.handle(
        _infoHashMeta,
        infoHash.isAcceptableOrUnknown(data['info_hash']!, _infoHashMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileTransferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileTransferRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      sizeBytes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}size_bytes'],
          )!,
      direction:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}direction'],
          )!,
      state:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}state'],
          )!,
      progressPercent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}progress_percent'],
          )!,
      peerCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}peer_count'],
          )!,
      speedBytesPerSec:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}speed_bytes_per_sec'],
          )!,
      infoHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}info_hash'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
    );
  }

  @override
  $FileTransfersTable createAlias(String alias) {
    return $FileTransfersTable(attachedDatabase, alias);
  }
}

class FileTransferRow extends DataClass implements Insertable<FileTransferRow> {
  final String id;
  final String name;
  final int sizeBytes;
  final int direction;
  final int state;
  final int progressPercent;
  final int peerCount;
  final int speedBytesPerSec;
  final String? infoHash;
  final String? localPath;
  const FileTransferRow({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.direction,
    required this.state,
    required this.progressPercent,
    required this.peerCount,
    required this.speedBytesPerSec,
    this.infoHash,
    this.localPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['direction'] = Variable<int>(direction);
    map['state'] = Variable<int>(state);
    map['progress_percent'] = Variable<int>(progressPercent);
    map['peer_count'] = Variable<int>(peerCount);
    map['speed_bytes_per_sec'] = Variable<int>(speedBytesPerSec);
    if (!nullToAbsent || infoHash != null) {
      map['info_hash'] = Variable<String>(infoHash);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    return map;
  }

  FileTransfersCompanion toCompanion(bool nullToAbsent) {
    return FileTransfersCompanion(
      id: Value(id),
      name: Value(name),
      sizeBytes: Value(sizeBytes),
      direction: Value(direction),
      state: Value(state),
      progressPercent: Value(progressPercent),
      peerCount: Value(peerCount),
      speedBytesPerSec: Value(speedBytesPerSec),
      infoHash:
          infoHash == null && nullToAbsent
              ? const Value.absent()
              : Value(infoHash),
      localPath:
          localPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localPath),
    );
  }

  factory FileTransferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileTransferRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      direction: serializer.fromJson<int>(json['direction']),
      state: serializer.fromJson<int>(json['state']),
      progressPercent: serializer.fromJson<int>(json['progressPercent']),
      peerCount: serializer.fromJson<int>(json['peerCount']),
      speedBytesPerSec: serializer.fromJson<int>(json['speedBytesPerSec']),
      infoHash: serializer.fromJson<String?>(json['infoHash']),
      localPath: serializer.fromJson<String?>(json['localPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'direction': serializer.toJson<int>(direction),
      'state': serializer.toJson<int>(state),
      'progressPercent': serializer.toJson<int>(progressPercent),
      'peerCount': serializer.toJson<int>(peerCount),
      'speedBytesPerSec': serializer.toJson<int>(speedBytesPerSec),
      'infoHash': serializer.toJson<String?>(infoHash),
      'localPath': serializer.toJson<String?>(localPath),
    };
  }

  FileTransferRow copyWith({
    String? id,
    String? name,
    int? sizeBytes,
    int? direction,
    int? state,
    int? progressPercent,
    int? peerCount,
    int? speedBytesPerSec,
    Value<String?> infoHash = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
  }) => FileTransferRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    direction: direction ?? this.direction,
    state: state ?? this.state,
    progressPercent: progressPercent ?? this.progressPercent,
    peerCount: peerCount ?? this.peerCount,
    speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
    infoHash: infoHash.present ? infoHash.value : this.infoHash,
    localPath: localPath.present ? localPath.value : this.localPath,
  );
  FileTransferRow copyWithCompanion(FileTransfersCompanion data) {
    return FileTransferRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      direction: data.direction.present ? data.direction.value : this.direction,
      state: data.state.present ? data.state.value : this.state,
      progressPercent:
          data.progressPercent.present
              ? data.progressPercent.value
              : this.progressPercent,
      peerCount: data.peerCount.present ? data.peerCount.value : this.peerCount,
      speedBytesPerSec:
          data.speedBytesPerSec.present
              ? data.speedBytesPerSec.value
              : this.speedBytesPerSec,
      infoHash: data.infoHash.present ? data.infoHash.value : this.infoHash,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileTransferRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('direction: $direction, ')
          ..write('state: $state, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('peerCount: $peerCount, ')
          ..write('speedBytesPerSec: $speedBytesPerSec, ')
          ..write('infoHash: $infoHash, ')
          ..write('localPath: $localPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sizeBytes,
    direction,
    state,
    progressPercent,
    peerCount,
    speedBytesPerSec,
    infoHash,
    localPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileTransferRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sizeBytes == this.sizeBytes &&
          other.direction == this.direction &&
          other.state == this.state &&
          other.progressPercent == this.progressPercent &&
          other.peerCount == this.peerCount &&
          other.speedBytesPerSec == this.speedBytesPerSec &&
          other.infoHash == this.infoHash &&
          other.localPath == this.localPath);
}

class FileTransfersCompanion extends UpdateCompanion<FileTransferRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sizeBytes;
  final Value<int> direction;
  final Value<int> state;
  final Value<int> progressPercent;
  final Value<int> peerCount;
  final Value<int> speedBytesPerSec;
  final Value<String?> infoHash;
  final Value<String?> localPath;
  final Value<int> rowid;
  const FileTransfersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.direction = const Value.absent(),
    this.state = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.peerCount = const Value.absent(),
    this.speedBytesPerSec = const Value.absent(),
    this.infoHash = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileTransfersCompanion.insert({
    required String id,
    required String name,
    required int sizeBytes,
    required int direction,
    required int state,
    this.progressPercent = const Value.absent(),
    this.peerCount = const Value.absent(),
    this.speedBytesPerSec = const Value.absent(),
    this.infoHash = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sizeBytes = Value(sizeBytes),
       direction = Value(direction),
       state = Value(state);
  static Insertable<FileTransferRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sizeBytes,
    Expression<int>? direction,
    Expression<int>? state,
    Expression<int>? progressPercent,
    Expression<int>? peerCount,
    Expression<int>? speedBytesPerSec,
    Expression<String>? infoHash,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (direction != null) 'direction': direction,
      if (state != null) 'state': state,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (peerCount != null) 'peer_count': peerCount,
      if (speedBytesPerSec != null) 'speed_bytes_per_sec': speedBytesPerSec,
      if (infoHash != null) 'info_hash': infoHash,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileTransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sizeBytes,
    Value<int>? direction,
    Value<int>? state,
    Value<int>? progressPercent,
    Value<int>? peerCount,
    Value<int>? speedBytesPerSec,
    Value<String?>? infoHash,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return FileTransfersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      progressPercent: progressPercent ?? this.progressPercent,
      peerCount: peerCount ?? this.peerCount,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      infoHash: infoHash ?? this.infoHash,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<int>(progressPercent.value);
    }
    if (peerCount.present) {
      map['peer_count'] = Variable<int>(peerCount.value);
    }
    if (speedBytesPerSec.present) {
      map['speed_bytes_per_sec'] = Variable<int>(speedBytesPerSec.value);
    }
    if (infoHash.present) {
      map['info_hash'] = Variable<String>(infoHash.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileTransfersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('direction: $direction, ')
          ..write('state: $state, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('peerCount: $peerCount, ')
          ..write('speedBytesPerSec: $speedBytesPerSec, ')
          ..write('infoHash: $infoHash, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReactionsTable extends Reactions
    with TableInfo<$ReactionsTable, ReactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    chatId,
    userId,
    emoji,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, userId, emoji};
  @override
  ReactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionRow(
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      emoji:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}emoji'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ReactionsTable createAlias(String alias) {
    return $ReactionsTable(attachedDatabase, alias);
  }
}

class ReactionRow extends DataClass implements Insertable<ReactionRow> {
  final String messageId;
  final String chatId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  const ReactionRow({
    required this.messageId,
    required this.chatId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['chat_id'] = Variable<String>(chatId);
    map['user_id'] = Variable<String>(userId);
    map['emoji'] = Variable<String>(emoji);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReactionsCompanion toCompanion(bool nullToAbsent) {
    return ReactionsCompanion(
      messageId: Value(messageId),
      chatId: Value(chatId),
      userId: Value(userId),
      emoji: Value(emoji),
      createdAt: Value(createdAt),
    );
  }

  factory ReactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionRow(
      messageId: serializer.fromJson<String>(json['messageId']),
      chatId: serializer.fromJson<String>(json['chatId']),
      userId: serializer.fromJson<String>(json['userId']),
      emoji: serializer.fromJson<String>(json['emoji']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'chatId': serializer.toJson<String>(chatId),
      'userId': serializer.toJson<String>(userId),
      'emoji': serializer.toJson<String>(emoji),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReactionRow copyWith({
    String? messageId,
    String? chatId,
    String? userId,
    String? emoji,
    DateTime? createdAt,
  }) => ReactionRow(
    messageId: messageId ?? this.messageId,
    chatId: chatId ?? this.chatId,
    userId: userId ?? this.userId,
    emoji: emoji ?? this.emoji,
    createdAt: createdAt ?? this.createdAt,
  );
  ReactionRow copyWithCompanion(ReactionsCompanion data) {
    return ReactionRow(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      userId: data.userId.present ? data.userId.value : this.userId,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionRow(')
          ..write('messageId: $messageId, ')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, chatId, userId, emoji, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionRow &&
          other.messageId == this.messageId &&
          other.chatId == this.chatId &&
          other.userId == this.userId &&
          other.emoji == this.emoji &&
          other.createdAt == this.createdAt);
}

class ReactionsCompanion extends UpdateCompanion<ReactionRow> {
  final Value<String> messageId;
  final Value<String> chatId;
  final Value<String> userId;
  final Value<String> emoji;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReactionsCompanion({
    this.messageId = const Value.absent(),
    this.chatId = const Value.absent(),
    this.userId = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionsCompanion.insert({
    required String messageId,
    required String chatId,
    required String userId,
    required String emoji,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       chatId = Value(chatId),
       userId = Value(userId),
       emoji = Value(emoji);
  static Insertable<ReactionRow> custom({
    Expression<String>? messageId,
    Expression<String>? chatId,
    Expression<String>? userId,
    Expression<String>? emoji,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (chatId != null) 'chat_id': chatId,
      if (userId != null) 'user_id': userId,
      if (emoji != null) 'emoji': emoji,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionsCompanion copyWith({
    Value<String>? messageId,
    Value<String>? chatId,
    Value<String>? userId,
    Value<String>? emoji,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReactionsCompanion(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $FileTransfersTable fileTransfers = $FileTransfersTable(this);
  late final $ReactionsTable reactions = $ReactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contacts,
    chats,
    messages,
    fileTransfers,
    reactions,
  ];
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      required String id,
      required String name,
      required String nodeId,
      required Uint8List publicKey,
      Value<int> mode,
      Value<int> signalLevel,
      Value<bool> isOnline,
      Value<int?> distanceMeters,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> nodeId,
      Value<Uint8List> publicKey,
      Value<int> mode,
      Value<int> signalLevel,
      Value<bool> isOnline,
      Value<int?> distanceMeters,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get signalLevel => $composableBuilder(
    column: $table.signalLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalLevel => $composableBuilder(
    column: $table.signalLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get signalLevel => $composableBuilder(
    column: $table.signalLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactRow,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (
            ContactRow,
            BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>,
          ),
          ContactRow,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<Uint8List> publicKey = const Value.absent(),
                Value<int> mode = const Value.absent(),
                Value<int> signalLevel = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<int?> distanceMeters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                name: name,
                nodeId: nodeId,
                publicKey: publicKey,
                mode: mode,
                signalLevel: signalLevel,
                isOnline: isOnline,
                distanceMeters: distanceMeters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String nodeId,
                required Uint8List publicKey,
                Value<int> mode = const Value.absent(),
                Value<int> signalLevel = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<int?> distanceMeters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                name: name,
                nodeId: nodeId,
                publicKey: publicKey,
                mode: mode,
                signalLevel: signalLevel,
                isOnline: isOnline,
                distanceMeters: distanceMeters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactRow,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (ContactRow, BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>),
      ContactRow,
      PrefetchHooks Function()
    >;
typedef $$ChatsTableCreateCompanionBuilder =
    ChatsCompanion Function({
      required String id,
      required String contactId,
      required String displayName,
      Value<String?> lastMessage,
      Value<DateTime?> lastMessageTime,
      Value<int> unreadCount,
      Value<bool> isGroup,
      Value<int?> memberCount,
      Value<int> rowid,
    });
typedef $$ChatsTableUpdateCompanionBuilder =
    ChatsCompanion Function({
      Value<String> id,
      Value<String> contactId,
      Value<String> displayName,
      Value<String?> lastMessage,
      Value<DateTime?> lastMessageTime,
      Value<int> unreadCount,
      Value<bool> isGroup,
      Value<int?> memberCount,
      Value<int> rowid,
    });

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatsTable,
          ChatRow,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (ChatRow, BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>),
          ChatRow,
          PrefetchHooks Function()
        > {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<DateTime?> lastMessageTime = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<int?> memberCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion(
                id: id,
                contactId: contactId,
                displayName: displayName,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount,
                isGroup: isGroup,
                memberCount: memberCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contactId,
                required String displayName,
                Value<String?> lastMessage = const Value.absent(),
                Value<DateTime?> lastMessageTime = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<int?> memberCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion.insert(
                id: id,
                contactId: contactId,
                displayName: displayName,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount,
                isGroup: isGroup,
                memberCount: memberCount,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatsTable,
      ChatRow,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (ChatRow, BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>),
      ChatRow,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String chatId,
      required int kind,
      required DateTime timestamp,
      required bool isOutgoing,
      Value<String?> body,
      Value<String?> filePath,
      Value<String?> fileName,
      Value<int?> fileSizeBytes,
      Value<int?> durationSeconds,
      Value<int> status,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<int> kind,
      Value<DateTime> timestamp,
      Value<bool> isOutgoing,
      Value<String?> body,
      Value<String?> filePath,
      Value<String?> fileName,
      Value<int?> fileSizeBytes,
      Value<int?> durationSeconds,
      Value<int> status,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessageRow,
            BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>,
          ),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isOutgoing = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                chatId: chatId,
                kind: kind,
                timestamp: timestamp,
                isOutgoing: isOutgoing,
                body: body,
                filePath: filePath,
                fileName: fileName,
                fileSizeBytes: fileSizeBytes,
                durationSeconds: durationSeconds,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required int kind,
                required DateTime timestamp,
                required bool isOutgoing,
                Value<String?> body = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                chatId: chatId,
                kind: kind,
                timestamp: timestamp,
                isOutgoing: isOutgoing,
                body: body,
                filePath: filePath,
                fileName: fileName,
                fileSizeBytes: fileSizeBytes,
                durationSeconds: durationSeconds,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$FileTransfersTableCreateCompanionBuilder =
    FileTransfersCompanion Function({
      required String id,
      required String name,
      required int sizeBytes,
      required int direction,
      required int state,
      Value<int> progressPercent,
      Value<int> peerCount,
      Value<int> speedBytesPerSec,
      Value<String?> infoHash,
      Value<String?> localPath,
      Value<int> rowid,
    });
typedef $$FileTransfersTableUpdateCompanionBuilder =
    FileTransfersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sizeBytes,
      Value<int> direction,
      Value<int> state,
      Value<int> progressPercent,
      Value<int> peerCount,
      Value<int> speedBytesPerSec,
      Value<String?> infoHash,
      Value<String?> localPath,
      Value<int> rowid,
    });

class $$FileTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $FileTransfersTable> {
  $$FileTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peerCount => $composableBuilder(
    column: $table.peerCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedBytesPerSec => $composableBuilder(
    column: $table.speedBytesPerSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get infoHash => $composableBuilder(
    column: $table.infoHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $FileTransfersTable> {
  $$FileTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peerCount => $composableBuilder(
    column: $table.peerCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedBytesPerSec => $composableBuilder(
    column: $table.speedBytesPerSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get infoHash => $composableBuilder(
    column: $table.infoHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileTransfersTable> {
  $$FileTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peerCount =>
      $composableBuilder(column: $table.peerCount, builder: (column) => column);

  GeneratedColumn<int> get speedBytesPerSec => $composableBuilder(
    column: $table.speedBytesPerSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get infoHash =>
      $composableBuilder(column: $table.infoHash, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$FileTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileTransfersTable,
          FileTransferRow,
          $$FileTransfersTableFilterComposer,
          $$FileTransfersTableOrderingComposer,
          $$FileTransfersTableAnnotationComposer,
          $$FileTransfersTableCreateCompanionBuilder,
          $$FileTransfersTableUpdateCompanionBuilder,
          (
            FileTransferRow,
            BaseReferences<_$AppDatabase, $FileTransfersTable, FileTransferRow>,
          ),
          FileTransferRow,
          PrefetchHooks Function()
        > {
  $$FileTransfersTableTableManager(_$AppDatabase db, $FileTransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FileTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$FileTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FileTransfersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> direction = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int> progressPercent = const Value.absent(),
                Value<int> peerCount = const Value.absent(),
                Value<int> speedBytesPerSec = const Value.absent(),
                Value<String?> infoHash = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileTransfersCompanion(
                id: id,
                name: name,
                sizeBytes: sizeBytes,
                direction: direction,
                state: state,
                progressPercent: progressPercent,
                peerCount: peerCount,
                speedBytesPerSec: speedBytesPerSec,
                infoHash: infoHash,
                localPath: localPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int sizeBytes,
                required int direction,
                required int state,
                Value<int> progressPercent = const Value.absent(),
                Value<int> peerCount = const Value.absent(),
                Value<int> speedBytesPerSec = const Value.absent(),
                Value<String?> infoHash = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileTransfersCompanion.insert(
                id: id,
                name: name,
                sizeBytes: sizeBytes,
                direction: direction,
                state: state,
                progressPercent: progressPercent,
                peerCount: peerCount,
                speedBytesPerSec: speedBytesPerSec,
                infoHash: infoHash,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FileTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileTransfersTable,
      FileTransferRow,
      $$FileTransfersTableFilterComposer,
      $$FileTransfersTableOrderingComposer,
      $$FileTransfersTableAnnotationComposer,
      $$FileTransfersTableCreateCompanionBuilder,
      $$FileTransfersTableUpdateCompanionBuilder,
      (
        FileTransferRow,
        BaseReferences<_$AppDatabase, $FileTransfersTable, FileTransferRow>,
      ),
      FileTransferRow,
      PrefetchHooks Function()
    >;
typedef $$ReactionsTableCreateCompanionBuilder =
    ReactionsCompanion Function({
      required String messageId,
      required String chatId,
      required String userId,
      required String emoji,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ReactionsTableUpdateCompanionBuilder =
    ReactionsCompanion Function({
      Value<String> messageId,
      Value<String> chatId,
      Value<String> userId,
      Value<String> emoji,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ReactionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReactionsTable> {
  $$ReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReactionsTable> {
  $$ReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReactionsTable> {
  $$ReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReactionsTable,
          ReactionRow,
          $$ReactionsTableFilterComposer,
          $$ReactionsTableOrderingComposer,
          $$ReactionsTableAnnotationComposer,
          $$ReactionsTableCreateCompanionBuilder,
          $$ReactionsTableUpdateCompanionBuilder,
          (
            ReactionRow,
            BaseReferences<_$AppDatabase, $ReactionsTable, ReactionRow>,
          ),
          ReactionRow,
          PrefetchHooks Function()
        > {
  $$ReactionsTableTableManager(_$AppDatabase db, $ReactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionsCompanion(
                messageId: messageId,
                chatId: chatId,
                userId: userId,
                emoji: emoji,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String chatId,
                required String userId,
                required String emoji,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionsCompanion.insert(
                messageId: messageId,
                chatId: chatId,
                userId: userId,
                emoji: emoji,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReactionsTable,
      ReactionRow,
      $$ReactionsTableFilterComposer,
      $$ReactionsTableOrderingComposer,
      $$ReactionsTableAnnotationComposer,
      $$ReactionsTableCreateCompanionBuilder,
      $$ReactionsTableUpdateCompanionBuilder,
      (
        ReactionRow,
        BaseReferences<_$AppDatabase, $ReactionsTable, ReactionRow>,
      ),
      ReactionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$FileTransfersTableTableManager get fileTransfers =>
      $$FileTransfersTableTableManager(_db, _db.fileTransfers);
  $$ReactionsTableTableManager get reactions =>
      $$ReactionsTableTableManager(_db, _db.reactions);
}
