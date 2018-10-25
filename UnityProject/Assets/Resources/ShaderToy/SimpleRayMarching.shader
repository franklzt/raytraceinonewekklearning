Shader "ShaderRayTraceInOneWeek/SimpleRayMarching" {
	SubShader{
	 Pass {
	CGPROGRAM

	#define iTime _Time.y
	#pragma vertex vert  
	#pragma fragment frag 
	#include "UnityCG.cginc"
	#pragma target 3.0      


	float maxcomp(float3 p){return max(p.x , max( p.y , p.z ) );}
	float sdBox(float3 p,float3 b)
	{
		float3 di = abs(p) - b;
		float mc = maxcomp(di);
		return min(mc, length(max(di,0.0)));
	}

	float3x3 ma = float3x3(0.60, 0.00,  0.80,
					  0.00, 1.00,  0.00,
					 -0.80, 0.00,  0.60);

	float4 map(float3 p)
	{
		float d = sdBox(p, float3(1.0,1.0,1.0));
		float4 res = float4(d, 1.0, 0.0, 0.0);

		float ani = smoothstep(-0.2, 0.2, -cos(0.5*iTime));
		float off = 1.5*sin(0.01*iTime);

		float s = 1.0;
		for (int m = 0; m < 4; m++)
		{
			float3 ms = p + off;
			p = lerp(p, mul(ma, ms), ani);

			float3 a = fmod(p*s, 2.0) - 1.0;
			s *= 3.0;
			float3 r = abs(1.0 - 3.0*abs(a));
			float da = max(r.x, r.y);
			float db = max(r.y, r.z);
			float dc = max(r.z, r.x);
			float c = (min(da, min(db, dc)) - 1.0) / s;

			if (c > d)
			{
				d = c;
				res = float4(d, min(res.y, 0.2*da*db*dc), (1.0 + float(m)) / 4.0, 0.0);
			}
		}
		return res;
	}


	float4 intersect(float3 ro, float3 rd)
	{
		float t = 0.0;
		float4 res = float4(-1.0,-1.0,-1.0,-1.0);
		float4 h = float4(1.0,1.0,1.0,1.0);
		for (int i = 0; i < 64; i++)
		{
			if (h.x<0.002 || t>10.0) break;
			h = map(ro + rd * t);
			res = float4(t, h.yzw);
			t += h.x;
		}
		if (t > 10.0) res = float4(-1.0, -1.0, -1.0, -1.0);
		return res;
	}


	float softshadow(float3 ro, float3 rd, float mint, float k)
	{
		float res = 1.0;
		float t = mint;
		float h = 1.0;
		for (int i = 0; i < 32; i++)
		{
			h = map(ro + rd * t).x;
			res = min(res, k*h / t);
			t += clamp(h, 0.005, 0.1);
		}
		return clamp(res, 0.0, 1.0);
	}

	float3 calcNormal(float3 pos)
	{
		float3  eps = float3(.001, 0.0, 0.0);
		float3 nor;
		nor.x = map(pos + eps.xyy).x - map(pos - eps.xyy).x;
		nor.y = map(pos + eps.yxy).x - map(pos - eps.yxy).x;
		nor.z = map(pos + eps.yyx).x - map(pos - eps.yyx).x;
		return normalize(nor);
	}


	float3 light = normalize(float3(1.0, 0.9, 0.3));


	float3 render(float3 ro, float3 rd)
	{
		float3 col = lerp(float3(0.3, 0.2, 0.1)*0.5, float3(0.7, 0.9, 1.0), 0.5 + 0.5*rd.y);

		float4 tmat = intersect(ro, rd);

		if (tmat.x > 0.0)
		{
			float3  pos = ro + tmat.x*rd;
			float3  nor = calcNormal(pos);

			float occ = tmat.y;
			float sha = softshadow(pos, light, 0.01, 64.0);

			float dif = max(0.1 + 0.9*dot(nor, light), 0.0);
			float sky = 0.5 + 0.5*nor.y;
			float bac = max(0.4 + 0.6*dot(nor, float3(-light.x, light.y, -light.z)), 0.0);

			float3 lin = float3(0.0,0.0,0.0);
			lin += 1.00*dif*float3(1.10, 0.85, 0.60)*sha;
			lin += 0.50*sky*float3(0.10, 0.20, 0.40)*occ;
			lin += 0.10*bac*float3(1.00, 1.00, 1.00)*(0.5 + 0.5*occ);
			lin += 0.25*occ*float3(0.15, 0.17, 0.20);

			float3 matcol = float3(
				0.5 + 0.5*cos(0.0 + 2.0*tmat.z),
				0.5 + 0.5*cos(1.0 + 2.0*tmat.z),
				0.5 + 0.5*cos(2.0 + 2.0*tmat.z));
			col = matcol * lin;
		}

		float f = 0.4545;
		return pow(col, float3(f,f,f));
	}


	float4 mainImage(float2 fragCoord)
	{
		float2 p = fragCoord;


		float ctime = _Time.y;
		float3 ro = 1.1*float3(2.5*sin(0.25*ctime), 1.0 + 1.0*cos(ctime*.13), 2.5*cos(0.25*ctime));
		float3 ww = normalize(float3(0.0,0.0,0.0) - ro);
		float3 uu = normalize(cross(float3(0.0, 1.0, 0.0), ww));
		float3 vv = normalize(cross(ww, uu));
		float3 rd = normalize(p.x*uu + p.y*vv + 2.5*ww);


		float3 col = render(ro, rd);
		float4 fragColor = float4(col, 1.0);
		return fragColor;
	}



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

	float4 frag(vertexOutput input) : COLOR
	{
		return mainImage(input.col);
	}

	ENDCG
	}
}
}
