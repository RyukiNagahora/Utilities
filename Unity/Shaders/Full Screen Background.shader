Shader "Full Screen Background"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
		_Color("Main Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "Queue"="Background+1" "RenderType" = "Transparent" }
		LOD 100
		Cull Off
		ZWrite Off
		ZTest Always
		Lighting Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainTex_TexelSize;
			uniform fixed4 _Color;

			float2 ScaleZoomToFit(float targetWidth, float targetHeight, float sourceWidth, float sourceHeight)
			{
				float targetAspect = targetHeight / targetWidth;
				float sourceAspect = sourceHeight / sourceWidth;
				float2 scale = float2(1.0, sourceAspect / targetAspect);
				if (targetAspect < sourceAspect)
				{
					scale = float2(targetAspect / sourceAspect, 1.0);
				}
				return scale;
			}

			float4 OffsetAlphaPackingUV(float2 texelSize, float2 uv, bool flipVertical)
			{
				float4 result = uv.xyxy;
				result.yw = result.wy;
				return result;
			}
			
			fixed4  SampleRGBA(sampler2D tex, float2 uv)
			{
				fixed4  rgba = tex2D(tex, uv);
				return rgba;
			}


			v2f vert (appdata_img v)
			{
				v2f o;

				float2 scale = ScaleZoomToFit(_ScreenParams.x, _ScreenParams.y, _MainTex_TexelSize.z, _MainTex_TexelSize.w);
				float2 pos = ((v.vertex.xy) * scale * 2.0);
				if (_ProjectionParams.x < 0.0)
				{
					pos.y = (1.0 - pos.y) - 1.0;
				}

				o.vertex = float4(pos.xy, UNITY_NEAR_CLIP_VALUE, 1.0);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				if (_MainTex_ST.y < 0.0)
				{
					o.uv.y = 1.0 - o.uv.y;
				}

				o.uv = OffsetAlphaPackingUV(_MainTex_TexelSize.xy, o.uv.xy, _MainTex_ST.y < 0.0);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = SampleRGBA(_MainTex, i.uv.xy);


				col *= _Color;

				return col;
			}
			ENDCG
		}
	}
}
