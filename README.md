いったん特定の個所をPCで長押しするとバーが進む感じで作っております．基本シェダーで制御できるんちょ．

Shaderに関して
  NiER:Automataゲーム画面から，adobeカラーパレットで抽出．透明度の調整が重要．
  Inner color: #C6C5B1 
  Outer Color: #917E6E
  Glowに関しても実装をしてみました．でもなんか色合いがびみょー．

C#に関して．
GPTを一部使用しました．**Particleを作ってみました．**　←機能しているのか！？

Particle Prefab
  新規のImage UIオブジェクトを作成
  円形テクスチャを割り当て（またはマスクで円形に）
  色を白に設定、透明度を約30%に設定
  サイズを適切に調整（例：32x32ピクセル）
  プレハブとして保存
  このプレハブをLongPressHandlerのparticlePrefabフィールドに割り当て

  
