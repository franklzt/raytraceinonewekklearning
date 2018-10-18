// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/BaseMixedColor" {
	Properties{
		iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
		iChannel0("iChannel0", 2D) = "white" {}
		iChannelResolution0("iChannelResolution0", Vector) = (100, 100, 0, 0)
	}

		CGINCLUDE
#include "UnityCG.cginc"   
#pragma target 3.0      

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define iGlobalTime _Time.y
#define mod fmod
#define mix lerp
#define fract frac
#define texture2D tex2D
#define iResolution _ScreenParams
#define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

#define PI2 6.28318530718
#define pi 3.14159265358979
#define halfpi (pi * 0.5)
#define oneoverpi (1.0 / pi)

			fixed4 iMouse;
		sampler2D iChannel0;
		float4 iChannel0_ST;

		fixed4 iChannelResolution0;

		struct v2f {
			float4 pos : SV_POSITION;
			float4 scrPos : TEXCOORD0;
			float4 texcoord : TEXCOORD1;

		};

		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.scrPos = ComputeScreenPos(o.pos);
			o.texcoord.xy = TRANSFORM_TEX(v.texcoord, iChannel0);
			return o;
		}


		float plot(vec2 st, float pct) {
			return  smoothstep(pct - 0.01, pct, st.y) -
				smoothstep(pct, pct + 0.01, st.y);
		}

		float rect(in vec2 st, in vec2 size) {
			size =  vec2(0.25,0.25) - size * 0.25;
			vec2 uv = smoothstep(size, size + size * vec2(0.002,0.002), st*(1.0 - st));
			return uv.x*uv.y;
		}

		vec4 main(vec2 fragCoord);

		fixed4 frag(v2f _iParam) : COLOR0{
			vec2 fragCoord = gl_FragCoord;
			vec2 viewPortCoor = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);// (0,0) - (1,1) 中心位置为(0.5,0.5)			
			vec2 coord = vec2(_iParam.texcoord.x, _iParam.texcoord.y);
			return main(_iParam.texcoord);
		}



		vec4 main(vec2 fragCoord) 
		{
			vec2 st = fragCoord;

			vec3 influenced_color = vec3(0.577, 0.441, 0.700);

			vec3 influencing_color_A = vec3(0.319, 0.167, 0.365);
			vec3 influencing_color_B = vec3(0.628, 0.526, 0.775);

			vec3 color = mix(influencing_color_A,
				influencing_color_B,
				step(.5, st.x));

			color = color * mix(influencing_color_A,
				influencing_color_B,
				step(.5, st.y));


			float tt = sin(iGlobalTime / 1.5);


			/*color = mix(color,
				influenced_color,
				rect(abs((st - vec2(.25, .0))*vec2(2., 1.)), vec2(.05, .125)));*/


			return vec4(color,1.0);
		}

		ENDCG

			SubShader{
				Pass {
					CGPROGRAM

					#pragma vertex vert    
					#pragma fragment frag    
					#pragma fragmentoption ARB_precision_hint_fastest     

					ENDCG
				}
		}
			FallBack Off
}