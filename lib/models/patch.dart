import 'package:json_annotation/json_annotation.dart';

part 'patch.g.dart';

enum LfoType { off, amp, filter, pitch, osc }

enum OscType { multiSaw, pulse, oscSync, ringMod, freqMod }

enum EffectType { distortion, chorusFlanger, phaser, delay, off }

@JsonSerializable()
class RefaceCsPatchData {
  RefaceCsPatchData({
    this.lfoType = LfoType.off,
    this.lfoDepth = 0,
    this.lfoSpeed = 0,
    this.portamento = 0,
    this.volume = 60,
    this.oscType = OscType.multiSaw,
    this.texture = 0,
    this.mod = 0,
    this.cutoff = 127,
    this.resonance = 0,
    this.fegAegBalance = 0,
    this.attack = 0,
    this.decay = 64,
    this.sustain = 127,
    this.release = 32,
    this.effectType = EffectType.off,
    this.effectDepth = 0,
    this.effectRate = 0,
  });

  // LFO section
  final LfoType lfoType; // 0-127
  final int lfoDepth; // 0-127
  final int lfoSpeed; // 0-127

  // Other
  final int portamento; // 0-127
  final int volume; // 0-127

  // Oscilator section
  final OscType oscType;
  final int texture; // 0-127
  final int mod; // 0-127

  // Filter section
  final int cutoff; // 0-127
  final int resonance; // 0-127

  // Env gen section
  final int fegAegBalance; // 0-127
  final int attack; // 0-127
  final int decay; // 0-127
  final int sustain; // 0-127
  final int release; // 0-127

  // Effect section
  final EffectType effectType;
  final int effectDepth; // 0-127
  final int effectRate; // 0-127

  RefaceCsPatchData copyWith({
    LfoType? lfoType,
    int? lfoDepth,
    int? lfoSpeed,
    int? portamento,
    int? volume,
    OscType? oscType,
    int? texture,
    int? mod,
    int? cutoff,
    int? resonance,
    int? fegAegBalance,
    int? attack,
    int? decay,
    int? sustain,
    int? release,
    EffectType? effectType,
    int? effectDepth,
    int? effectRate,
  }) {
    return RefaceCsPatchData(
      lfoType: lfoType ?? this.lfoType,
      lfoDepth: lfoDepth ?? this.lfoDepth,
      lfoSpeed: lfoSpeed ?? this.lfoSpeed,
      portamento: portamento ?? this.portamento,
      volume: volume ?? this.volume,
      oscType: oscType ?? this.oscType,
      texture: texture ?? this.texture,
      mod: mod ?? this.mod,
      cutoff: cutoff ?? this.cutoff,
      resonance: resonance ?? this.resonance,
      fegAegBalance: fegAegBalance ?? this.fegAegBalance,
      attack: attack ?? this.attack,
      decay: decay ?? this.decay,
      sustain: sustain ?? this.sustain,
      release: release ?? this.release,
      effectType: effectType ?? this.effectType,
      effectDepth: effectDepth ?? this.effectDepth,
      effectRate: effectRate ?? this.effectRate,
    );
  }

  // Raw value of a parameter; selector params return their enum index
  int get(RefaceCsParam param) => switch (param) {
    RefaceCsParam.volume => volume,
    RefaceCsParam.lfoType => lfoType.index,
    RefaceCsParam.lfoDepth => lfoDepth,
    RefaceCsParam.lfoSpeed => lfoSpeed,
    RefaceCsParam.portamento => portamento,
    RefaceCsParam.oscType => oscType.index,
    RefaceCsParam.texture => texture,
    RefaceCsParam.mod => mod,
    RefaceCsParam.cutoff => cutoff,
    RefaceCsParam.resonance => resonance,
    RefaceCsParam.fegAegBalance => fegAegBalance,
    RefaceCsParam.attack => attack,
    RefaceCsParam.decay => decay,
    RefaceCsParam.sustain => sustain,
    RefaceCsParam.release => release,
    RefaceCsParam.effectType => effectType.index,
    RefaceCsParam.effectDepth => effectDepth,
    RefaceCsParam.effectRate => effectRate,
  };

  // Copy with one parameter set from its raw value (enum index for selectors)
  RefaceCsPatchData withParam(RefaceCsParam param, int value) =>
      switch (param) {
        RefaceCsParam.volume => copyWith(volume: value),
        RefaceCsParam.lfoType => copyWith(lfoType: LfoType.values[value]),
        RefaceCsParam.lfoDepth => copyWith(lfoDepth: value),
        RefaceCsParam.lfoSpeed => copyWith(lfoSpeed: value),
        RefaceCsParam.portamento => copyWith(portamento: value),
        RefaceCsParam.oscType => copyWith(oscType: OscType.values[value]),
        RefaceCsParam.texture => copyWith(texture: value),
        RefaceCsParam.mod => copyWith(mod: value),
        RefaceCsParam.cutoff => copyWith(cutoff: value),
        RefaceCsParam.resonance => copyWith(resonance: value),
        RefaceCsParam.fegAegBalance => copyWith(fegAegBalance: value),
        RefaceCsParam.attack => copyWith(attack: value),
        RefaceCsParam.decay => copyWith(decay: value),
        RefaceCsParam.sustain => copyWith(sustain: value),
        RefaceCsParam.release => copyWith(release: value),
        RefaceCsParam.effectType => copyWith(
          effectType: EffectType.values[value],
        ),
        RefaceCsParam.effectDepth => copyWith(effectDepth: value),
        RefaceCsParam.effectRate => copyWith(effectRate: value),
      };

  factory RefaceCsPatchData.fromJson(Map<String, dynamic> json) =>
      _$RefaceCsPatchDataFromJson(json);
  Map<String, dynamic> toJson() => _$RefaceCsPatchDataToJson(this);
}

@JsonSerializable()
class Patch {
  Patch({required this.id, required this.name, required this.patchData});

  final String id;
  final String name;
  final RefaceCsPatchData patchData;

  Patch copyWith({String? id, String? name, RefaceCsPatchData? patchData}) {
    return Patch(
      id: id ?? this.id,
      name: name ?? this.name,
      patchData: patchData ?? this.patchData,
    );
  }

  factory Patch.fromJson(Map<String, dynamic> json) => _$PatchFromJson(json);
  Map<String, dynamic> toJson() => _$PatchToJson(this);
}

// Associate SysEx address, CC number, display name, enum values
enum RefaceCsParam {
  volume(0x00, label: 'Volume'),
  lfoType(0x02, cc: 78, label: 'LFO Assign', options: LfoType.values),
  lfoDepth(0x03, cc: 77, label: 'LFO Depth'),
  lfoSpeed(0x04, cc: 76, label: 'LFO Speed'),
  portamento(0x05, cc: 20, label: 'Portamento'),
  oscType(0x06, cc: 80, label: 'OSC Type', options: OscType.values),
  texture(0x07, cc: 81, label: 'OSC Texture'),
  mod(0x08, cc: 82, label: 'OSC Mod'),
  cutoff(0x09, cc: 74, label: 'Cutoff'),
  resonance(0x0A, cc: 71, label: 'Resonance'),
  fegAegBalance(0x0B, cc: 83, label: 'EG Balance'),
  attack(0x0C, cc: 73, label: 'Attack'),
  decay(0x0D, cc: 75, label: 'Decay'),
  sustain(0x0E, cc: 79, label: 'Sustain'),
  release(0x0F, cc: 72, label: 'Release'),
  effectType(0x10, cc: 17, label: 'Effect Type', options: EffectType.values),
  effectDepth(0x11, cc: 18, label: 'Effect Depth'),
  effectRate(0x12, cc: 19, label: 'Effect Rate');

  const RefaceCsParam(
    this.address, {
    required this.label,
    this.cc,
    this.options,
  });

  final int address;
  final String label;
  final int? cc;
  final List<Enum>? options;

  static final Map<int, RefaceCsParam> _byCc = {
    for (final param in values)
      if (param.cc != null) param.cc!: param,
  };

  static RefaceCsParam? fromCc(int cc) => _byCc[cc];
}
