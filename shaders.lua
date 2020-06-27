-- FILE: shaders.lua

shader = {}

local phong_shader = nil
local phong_shader_code = [[

#define MAX_LIGHTS 320
struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};
extern Light lights[MAX_LIGHTS];
extern int num_lights;
extern vec2 screen;
const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);
    vec2 norm_screen = screen_coords / screen;
    vec3 diffuse = vec3(0);
    for (int i = 0; i < num_lights; i++) {
        Light light = lights[i];
        vec2 norm_pos = light.position / screen;
        
        float distance = length(norm_pos - norm_screen) * light.power;
        float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
        diffuse += light.diffuse * attenuation;
    }
    diffuse = clamp(diffuse, 0.0, 1.0) + 0.6; // adding ambient light
    return pixel * vec4(diffuse, 1.0);
}
]]



function shader.init()
    phong_shader = love.graphics.newShader(phong_shader_code)
    -- Add aditional shader initialisations here..
end

function shader.apply()
    love.graphics.setShader(phong_shader)
    phong_shader:send("screen", {pixelWidth, pixelHeight})
    
    -- calculate number of light emmitters
    local light_counter = 0

    phong_shader:send("num_lights", #player.blasts + #enemy_blasts)

    -- player blasts
    for i=1,#player.blasts do
        local name = "lights[" .. light_counter .."]"
        phong_shader:send(name .. ".position", {player.blasts[i].pos_x*screenScale*2+8*screenScale, player.blasts[i].pos_y*screenScale*2+11*screenScale/2})
        phong_shader:send(name .. ".diffuse", {1.0, 1.0, 1.0})
        phong_shader:send(name .. ".power", 100)
        light_counter = light_counter + 1
    end
    -- enemy fire
    for i=1,#enemy_blasts do
        local name = "lights[" .. light_counter .."]"
        phong_shader:send(name .. ".position", {enemy_blasts[i].pos_x*screenScale*2+8*screenScale, enemy_blasts[i].pos_y*screenScale*2+11*screenScale/2})
        phong_shader:send(name .. ".diffuse", {1.0, 0.9, 0.9})
        phong_shader:send(name .. ".power", 100)
        light_counter = light_counter + 1
    end
end

function shader.remove()
    love.graphics.setShader()
end

