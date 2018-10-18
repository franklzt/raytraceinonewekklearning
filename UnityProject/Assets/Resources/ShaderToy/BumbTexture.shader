//在切线空间下的凹凸纹理实现
Shader "Custom/BumpTexture"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpTex("Bump Tex", 2D) = "Bump" {}
		_BumpScale("Bump Scale", Float) = 1
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
		SubShader
		{
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpTex;
				float4 _BumpTex_ST;
				float _BumpScale;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex : POSITION;
					// 将模型的法线方向存储到变量中
					float3 normal : NORMAL;
					// 将模型的第一组纹理坐标存储到变量中
					float3 texcoord : TEXCOORD0;
					// 将模型的顶点切线方向存储到变量中，float4的原因是用w来决定切线空间的第三个坐标轴——福切线的方向性。
					float4 tangent : TANGENT;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 lightDir : TEXCOORD0;
					fixed3 viewDir : TEXCOORD1;
					// 存储两个uv坐标 _MainTex 与 _BumpTex
					float4 uv : TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);

					// 计算福切线方向 叉乘获得与垂直于法线和切线平面的福切线方向，v.tangent.w 用来抉择福切线的方向（因为有两个方向）
					// 方法原理 float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
					// 模型空间到切线空间的变换矩阵
					// 方法原理 float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
					TANGENT_SPACE_ROTATION;

					// ObjSpaceLightDir(模型空间的光照方向)，转换成切线空间的光照方向。
					o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
					// 同上，转换的是视角方向
					o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

					// 对顶点纹理坐标进行变换，最终得到uv坐标。
					// 方法原理 o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					//_MainTex_ST 是纹理的属性值，写法是固定的为 纹理名+_ST
					o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// 切线空间的光照方向
					fixed3 tangentLightDir = normalize(i.lightDir);
				// 切线空间的视角方向
				fixed3 tangentViewDir = normalize(i.viewDir);

				// 对法线纹理进行采样
				fixed4 packedNormal = tex2D(_BumpTex, i.uv.zw);
				// 转换映射
				// 方法原理 tangentNormal.xy = (packedNormal.xy * 2 - 1);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				// 对纹理进行采样，返回为计算得到的纹素值，与_Color的乘积作为反射率
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				// 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				// 漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				// Blinn模型 计算
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
				// 高光反射
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				// 相加后输出颜色
				return fixed4(ambient + diffuse + specular, 1);
			}
			ENDCG
		}
		}
}