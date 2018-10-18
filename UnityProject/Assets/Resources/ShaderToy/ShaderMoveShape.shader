// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/ShaderMoveShape" {
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
#define u_time _Time.y
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



		float box(in vec2 _st, in vec2 _size) {
			_size = vec2(0.5,0.5) - _size * 0.5;
			vec2 uv = smoothstep(_size,
				_size + vec2(0.001,0.001),
				_st);
			uv *= smoothstep(_size,
				_size + vec2(0.001,0.001),
				vec2(1.0,1.0) - _st);
			return uv.x*uv.y;
		}

		float cross(in vec2 _st, float _size) {
			return  box(_st, vec2(_size, _size / 4.)) +
				box(_st, vec2(_size / 4., _size));
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

			vec3 color = vec3(0.0,0.0,0.0);

			// To move the cross we move the space
			vec2 translate = vec2(cos(u_time), sin(u_time));
			st += translate * 0.35;

			// Show the coordinates of the space on the background
			// color = vec3(st.x,st.y,0.0);

			// Add the shape on the foreground
			float crosf = cross(st, 0.25);

			float boxf = box(st, vec2(0.1, 0.1));
			float boxf2 = box(st, vec2(0.15, 0.15));

			crosf += boxf + boxf2;

			color = vec3(crosf , crosf, crosf);


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