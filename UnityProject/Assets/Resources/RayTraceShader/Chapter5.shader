Shader "ShaderRayTraceInOneWeek/Chapter5" {
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

////////////////////////////structs///////////////////////////////////////////////////////
		
		struct sphereStruct {
			float3 center;
			float radius;
		};

		struct hit_recordStruct {
			float t;
			float3 p;
			float3 normal;
		};
		
		struct rayOutputStruct{
			float3 origin;
			float3 direction;
		};


//////////////////////////////creates/////////////////////////////////////////////////////


		hit_recordStruct hit_record_create(float _t, float3 _p, float3 _normal)
		{
			hit_recordStruct record;
			record.t = _t;
			record.p = _p;
			record.normal = _normal;
			return record;
		}

		rayOutputStruct ray_create(float3 a, float3 b)
		{
			rayOutputStruct output;
			output.origin = a;
			output.direction = b;
			return output;
		}


//////////////////////////helpers/////////////////////////////////////////////////////////


		float3 ray_point_at_parameter(float t, rayOutputStruct r)
		{
			return r.origin + r.direction * t;
		}

		float ray_hit_sphere(float3 center, float radius, rayOutputStruct r)
		{
			float3 oc = r.origin - center;
			float a = dot(r.direction, r.direction);
			float b = 2.0 * dot(oc, r.direction);
			float c = dot(oc, oc) - radius * radius;
			float discriminant = b * b - 4 * a * c;
			if (discriminant < 0.0)
			{
				return -1.0;
			}
			else
			{
				return (-b - sqrt(discriminant)) / 2.0 * a;
			}
		}


		float3 ray_color(rayOutputStruct r)
		{
			float t = ray_hit_sphere(float3(0.0, 0.0, -1), 0.5, r);
			if (t > 0.0)
			{
				float3 N = normalize(ray_point_at_parameter(t, r) - float3(0.0, 0.0, -1));
				return 0.5 * float3(N.x + 1.0, N.y + 1.0, N.z + 1.0);
			}

			float3 unit_vector = normalize(r.direction);
			 t = 0.5 * (unit_vector.y + 1.0);
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
