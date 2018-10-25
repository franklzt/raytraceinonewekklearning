Shader "ShaderRayTraceInOneWeek/Chapter4" {
	SubShader{
	 Pass {
		CGPROGRAM

		#pragma vertex vert  
		#pragma fragment frag 
		#include "UnityCG.cginc"

		struct vertexOutput {
		   float4 pos : SV_POSITION;
		   float4 col : TEXCOORD0;
		};

		vertexOutput vert(appdata_full input)
		{
			vertexOutput output;
			output.pos = UnityObjectToClipPos(input.vertex);
			output.col = input.texcoord;
			return output;
		}

///////////////////////////////////////////////////////////////////////////////////
		struct rayOutputStruct{
			float3 origin;
			float3 direction;
		};

		rayOutputStruct ray_create(float3 a, float3 b)
		{
			rayOutputStruct output;
			output.origin = a;
			output.direction = b;
			return output;
		}

		float3 ray_point_at_parameter(float t, rayOutputStruct r)
		{
			return r.origin + r.direction * t;
		}

		bool ray_hit_sphere(float3 center, float radius, rayOutputStruct r)
		{
			float3 oc = r.origin - center;
			float a = dot(r.direction, r.direction);
			float b = 2.0 * dot(oc, r.direction);
			float c = dot(oc, oc) - radius * radius;
			float discriminant = b * b - 4 * a * c;
			return discriminant > 0.0;
		}

		



		float3 ray_color(rayOutputStruct r)
		{
			if (ray_hit_sphere(float3(0.0, 0.0, -1.0), 0.5, r))
			{
				return float3(1.0,0.0,0.0);
			}

			float3 unit_vector = normalize(r.direction);
			float t = 0.5 * (unit_vector.y + 1.0);
			return (1.0 - t) * float3(1.0, 1.0, 1.0) + t * float3(0.5, 0.7, 1.0);
		}

///////////////////////////////////////////////////////////////////////////////////

		
		float4 frag(vertexOutput input) : COLOR
		{
			float3 lower_left = float3(-2.0,-1.0,-1.0);
			float3 horizontal = float3(4.0, 0.0, 0.0);
			float3 vertical = float3(0.0, 2.0, 0.0);
			float3 original = float3(0.0, 0.0, 0.0);

			float2 uv = input.col.xy;

			rayOutputStruct r = ray_create(original, lower_left + uv.x * horizontal + vertical * uv.y);
			float3 rayOutputStruct = ray_color(r);
			float4 color = float4(rayOutputStruct,1.0);
		   return color;
		}

		ENDCG
	 }
	}
}
