Shader "Unlit/UnlitTextureAnimationShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
		_MaskTex("MaskTexture", 2D) = "white" {}
		//_Contrast("Contrast",Range(1,20)) = 10
		_MaskContrast("MaskContrast",Range(1,20)) = 10
		_Color("Main Color", Color) = (1,1,1,1)
    }
    SubShader
    {
		Tags { "RenderType" = "Fade" "Queue" = "Geometry" }
		LOD 200
		ZWrite Off
		Cull off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _MaskTex;
			//float _Contrast;
			float _MaskContrast;
			uniform fixed4 _Color;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 mask = tex2D(_MaskTex, i.uv);
				//col = 1 / (1 + exp(-_Contrast * (col - 0.5)));
				mask = 1 / (1 + exp(-_MaskContrast * (mask - 0.5)));

				col.a =  mask.a;
				col *= _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
