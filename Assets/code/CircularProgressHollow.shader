Shader "UI/GlowingCircularRing"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _GlowColor ("Glow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BackgroundColor ("Background Color", Color) = (0.1, 0.1, 0.1, 0.1)
        _Progress ("Progress", Range(0, 1)) = 0.75
        
        _OuterRadius ("Outer Radius", Range(0, 0.5)) = 0.45
        _InnerRadius ("Inner Radius", Range(0, 0.5)) = 0.35
        
        _GlowIntensity ("Glow Intensity", Range(1, 10)) = 3.0
        _GlowSize ("Glow Size", Range(0, 0.1)) = 0.03
        
        _SegmentCount ("Segment Count", Int) = 36
        _SegmentLength ("Segment Length", Range(0, 1)) = 0.9
        
        _RotationSpeed ("Rotation Speed", Range(-1, 1)) = 0.05
        _PulseSpeed ("Pulse Speed", Range(0, 5)) = 1.0
        _PulseIntensity ("Pulse Intensity", Range(0, 0.2)) = 0.05
        
        _EmissionMultiplier ("Emission Multiplier", Range(1, 5)) = 2.0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        Blend SrcAlpha One // Additive blending for glow
        ZWrite Off
        Cull Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            #define PI 3.14159265359
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 screenPos : TEXCOORD1; // Added for aspect ratio calculation
            };
            
            float4 _MainColor;
            float4 _GlowColor;
            float4 _BackgroundColor;
            float _Progress;
            float _OuterRadius;
            float _InnerRadius;
            float _GlowIntensity;
            float _GlowSize;
            int _SegmentCount;
            float _SegmentLength;
            float _RotationSpeed;
            float _PulseSpeed;
            float _PulseIntensity;
            float _EmissionMultiplier;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Center coordinates - ensure we're working with a perfect circle
                float2 center = float2(0.5, 0.5);
                float2 uv = i.uv - center;
                
                // Correct aspect ratio to ensure circle, not oval
                float aspect = 1.0; // Set to _ScreenParams.x/_ScreenParams.y if needed for screen space
                uv.x *= aspect;
                
                // Apply rotation - maintain perfect circle
                float rotation = _Time.y * _RotationSpeed;
                float2 rotatedUV;
                rotatedUV.x = uv.x * cos(rotation) - uv.y * sin(rotation);
                rotatedUV.y = uv.x * sin(rotation) + uv.y * cos(rotation);
                uv = rotatedUV;
                
                // Calculate distance from center
                float dist = length(uv);
                
                // Apply pulsing effect
                float pulse = 1.0 + sin(_Time.y * _PulseSpeed) * _PulseIntensity;
                float outerRadius = _OuterRadius * pulse;
                float innerRadius = _InnerRadius * pulse;
                
                // Create base ring with perfect circular shape
                float outerMask = smoothstep(outerRadius + _GlowSize, outerRadius - _GlowSize, dist);
                float innerMask = smoothstep(innerRadius - _GlowSize, innerRadius + _GlowSize, dist);
                float ring = outerMask * innerMask;
                
                // Calculate angle for segments and progress
                float angle = atan2(uv.y, uv.x);
                angle = (angle + PI) / (2.0 * PI); // Normalize to 0-1 range
                
                // Create segments
                float segmentAngle = 1.0 / float(_SegmentCount);
                float segmentMask = 0.0;
                
                if (_SegmentCount > 0) {
                    float segmentOffset = frac(angle / segmentAngle);
                    segmentMask = step(segmentOffset, _SegmentLength * segmentAngle);
                } else {
                    segmentMask = 1.0; // No segments, full ring
                }
                
                // Apply progress
                float progressAngle = _Progress * 2.0 * PI;
                float currentAngle = (atan2(uv.y, uv.x) + PI);
                float progressMask = step(currentAngle, progressAngle);
                
                // Calculate glow
                float glow = ring * segmentMask;
                
                // Add special symbols/markings - ensuring circular placement
                float symbols = 0.0;
                for (int j = 0; j < 12; j++) {
                    float symAngle = j * (2.0 * PI / 12.0);
                    float2 symPos = float2(cos(symAngle), sin(symAngle)) * ((outerRadius + innerRadius) * 0.5);
                    float symDist = length(uv - symPos);
                    
                    // Small dot symbol
                    if (j % 3 == 0) {
                        symbols += smoothstep(0.02, 0.0, symDist) * 
                                  smoothstep(0.5, 0.0, abs(dist - ((outerRadius + innerRadius) * 0.5))) * 0.7;
                    }
                    
                    // Line symbol
                    if (j % 3 == 1) {
                        float2 perpDir = float2(-symPos.y, symPos.x) * 0.03;
                        float lineDist = length(cross(float3(uv - symPos, 0), float3(perpDir, 0))) / length(perpDir);
                        symbols += smoothstep(0.007, 0.0, lineDist) * 
                                  smoothstep(0.05, 0.0, abs(dot(normalize(uv - symPos), normalize(symPos)))) * 0.5;
                    }
                }
                
                // Apply progress to symbols
                symbols *= progressMask;
                
                // Combine all effects
                float fullGlow = glow * progressMask;
                float backgroundGlow = glow * (1.0 - progressMask) * 0.3;
                
                // Intensify the glow where needed
                float enhancedGlow = pow(fullGlow, 0.7) * _GlowIntensity;
                
                // Calculate final color
                fixed4 col = _GlowColor * enhancedGlow * _EmissionMultiplier;
                col += _MainColor * symbols * _EmissionMultiplier;
                col += _BackgroundColor * backgroundGlow;
                
                // Apply alpha
                col.a = saturate(enhancedGlow + symbols + backgroundGlow) * i.color.a;
                
                return col;
            }
            ENDCG
        }
    }
}