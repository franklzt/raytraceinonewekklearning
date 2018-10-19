// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderRayTraceInOneWeek/Chapter4" {
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

#define LOWER_LEFT_CORNER vec3(-2.0f, -1.0f, -1.0f)
#define	HORIZONTAL  vec3(4.0f, 0.0f, 0.0f)
#define	VERTICAL   vec3(0.0f, 2.0f, 0.0f)
#define START_POINT vec3(0.0f, 2.0f, 0.0f)


			fixed4 iMouse;
		sampler2D iChannel0;
		fixed4 iChannelResolution0;

		struct v2f {
			float4 pos : SV_POSITION;
			float4 scrPos : TEXCOORD0;
		};

		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.scrPos = ComputeScreenPos(o.pos);
			return o;
		}

	

		float hit_sphere(vec3 center, float raduis, vec3 original, vec3 direction)
		{
			vec3 oc = original - center;
			float a = dot(direction, direction);
			float b = 2.0 * dot(oc, direction);
			float c = dot(oc, oc) - raduis * raduis;
			float discriminant = b * b - 4.0 * a * c;
			return discriminant;
		}


		vec3 get_color(vec3 original, vec3 direction)
		{

			vec3 hited_color = vec3(1.0, 0.0, 0.0);

			vec3 unit_v = normalize(direction);
			float t = 0.5 * (unit_v.y + 1.0);
			vec3 unhit_color = (1.0 - t) * vec3(1.0, 1.0, 1.0) + t * vec3(0.5, 0.7, 1.0);

			float hit = hit_sphere(vec3(0.0, 0.0, -1.0), 0.5, original, direction);				
			return smoothstep(unhit_color, hited_color, hit);
		}


		vec4 main(vec2 fragCoord);

		fixed4 frag(v2f _iParam) : COLOR0
		{
			vec2 fragCoord = gl_FragCoord;
			float2 viewPortCoor = float2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);// (0,0) - (1,1) 中心位置为(0.5,0.5)
			return main(viewPortCoor);
		}

		vec4 main(vec2 fragCoord)
		{
			vec2 st = fragCoord;
			float u = st.x;
			float v = st.y;
			
			vec3 dir = LOWER_LEFT_CORNER + u * HORIZONTAL + v * VERTICAL;
			vec3 col = get_color(START_POINT, dir);
			return vec4(col, 1.0);
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