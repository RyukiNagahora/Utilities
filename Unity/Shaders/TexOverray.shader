Shader "Unlit/Texture-Overlay" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _OverlayTex ("Overlay Texture", 2D) = "white" {}
        [KeywordEnum(Normal,Multiply,Screen)] _BlendMode ("Blend Mode", Float) = 0
        _Strength("Strength", Range(0, 1)) = 1
    }

    SubShader {
        Tags { "RenderType"="Transparent"  "Queue" = "Transparent" }
        LOD 100

        Pass {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                #pragma multi_compile_fog
                #pragma multi_compile _BLENDMODE_NORMAL _BLENDMODE_MULTIPLY  _BLENDMODE_SCREEN

                #include "UnityCG.cginc"

                struct appdata_t {
                    float4 vertex : POSITION;
                    float2 texcoord : TEXCOORD0;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    float2 texcoord : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _OverlayTex;
                float _Strength;

                v2f vert (appdata_t v)
                {
                    v2f o;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.texcoord);

                    fixed4 overlayCol  = tex2D (_OverlayTex, i.texcoord);

                    #ifdef _BLENDMODE_NORMAL
                        col.r +=  (overlayCol.r - col.r) *  _Strength;
                        col.g +=   (overlayCol.g - col.g) *  _Strength;
                        col.b +=   (overlayCol.b - col.b) *  _Strength;
                    #elif _BLENDMODE_MULTIPLY
                        col.r *= 1 - (1 - overlayCol.r) * _Strength;
                        col.g *= 1 - (1 - overlayCol.g) * _Strength;
                        col.b *= 1 - (1 - overlayCol.b) * _Strength;
                    #elif _BLENDMODE_SCREEN
                        col.r = 1 - (1-col.r ) * (1 - overlayCol.r * _Strength);
                        col.g = 1 - (1-col.g ) * (1 - overlayCol.g * _Strength);
                        col.b = 1 - (1-col.b ) * (1 - overlayCol.b * _Strength);
                    #endif

                    UNITY_APPLY_FOG(i.fogCoord, col);
                    UNITY_OPAQUE_ALPHA(col.a);

                    fixed4 ol = tex2D(_MainTex, i.texcoord);
                    col.a = ol.a;

                    return col;
                }
            ENDCG
        }
    }

}