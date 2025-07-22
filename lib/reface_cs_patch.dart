enum LfoType { off, amp, filter, pitch, osc }

enum OscType { freqMod, ringMod, oscSync, pulse, multiSaw }

enum EffectType { distortion, chorusFlanger, phaser, delay, off }

class RefaceCsPatch {
  RefaceCsPatch({
    this.lfoType = LfoType.off,
    this.lfoDepth = 0,
    this.lfoSpeed = 0,
    this.portamento = 0,
    this.volume = 100,
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

  RefaceCsPatch copyWith({
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
    return RefaceCsPatch(
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
}
