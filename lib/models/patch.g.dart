// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefaceCsPatchData _$RefaceCsPatchDataFromJson(Map<String, dynamic> json) =>
    RefaceCsPatchData(
      lfoType:
          $enumDecodeNullable(_$LfoTypeEnumMap, json['lfoType']) ?? LfoType.off,
      lfoDepth: (json['lfoDepth'] as num?)?.toInt() ?? 0,
      lfoSpeed: (json['lfoSpeed'] as num?)?.toInt() ?? 0,
      portamento: (json['portamento'] as num?)?.toInt() ?? 0,
      volume: (json['volume'] as num?)?.toInt() ?? 60,
      oscType:
          $enumDecodeNullable(_$OscTypeEnumMap, json['oscType']) ??
          OscType.multiSaw,
      texture: (json['texture'] as num?)?.toInt() ?? 0,
      mod: (json['mod'] as num?)?.toInt() ?? 0,
      cutoff: (json['cutoff'] as num?)?.toInt() ?? 127,
      resonance: (json['resonance'] as num?)?.toInt() ?? 0,
      fegAegBalance: (json['fegAegBalance'] as num?)?.toInt() ?? 0,
      attack: (json['attack'] as num?)?.toInt() ?? 0,
      decay: (json['decay'] as num?)?.toInt() ?? 64,
      sustain: (json['sustain'] as num?)?.toInt() ?? 127,
      release: (json['release'] as num?)?.toInt() ?? 32,
      effectType:
          $enumDecodeNullable(_$EffectTypeEnumMap, json['effectType']) ??
          EffectType.off,
      effectDepth: (json['effectDepth'] as num?)?.toInt() ?? 0,
      effectRate: (json['effectRate'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RefaceCsPatchDataToJson(RefaceCsPatchData instance) =>
    <String, dynamic>{
      'lfoType': _$LfoTypeEnumMap[instance.lfoType]!,
      'lfoDepth': instance.lfoDepth,
      'lfoSpeed': instance.lfoSpeed,
      'portamento': instance.portamento,
      'volume': instance.volume,
      'oscType': _$OscTypeEnumMap[instance.oscType]!,
      'texture': instance.texture,
      'mod': instance.mod,
      'cutoff': instance.cutoff,
      'resonance': instance.resonance,
      'fegAegBalance': instance.fegAegBalance,
      'attack': instance.attack,
      'decay': instance.decay,
      'sustain': instance.sustain,
      'release': instance.release,
      'effectType': _$EffectTypeEnumMap[instance.effectType]!,
      'effectDepth': instance.effectDepth,
      'effectRate': instance.effectRate,
    };

const _$LfoTypeEnumMap = {
  LfoType.off: 'off',
  LfoType.amp: 'amp',
  LfoType.filter: 'filter',
  LfoType.pitch: 'pitch',
  LfoType.osc: 'osc',
};

const _$OscTypeEnumMap = {
  OscType.multiSaw: 'multiSaw',
  OscType.pulse: 'pulse',
  OscType.oscSync: 'oscSync',
  OscType.ringMod: 'ringMod',
  OscType.freqMod: 'freqMod',
};

const _$EffectTypeEnumMap = {
  EffectType.distortion: 'distortion',
  EffectType.chorusFlanger: 'chorusFlanger',
  EffectType.phaser: 'phaser',
  EffectType.delay: 'delay',
  EffectType.off: 'off',
};

Patch _$PatchFromJson(Map<String, dynamic> json) => Patch(
  id: json['id'] as String,
  name: json['name'] as String,
  patchData: RefaceCsPatchData.fromJson(
    json['patchData'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$PatchToJson(Patch instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'patchData': instance.patchData,
};
