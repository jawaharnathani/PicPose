import json

objs = [
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"2e20a308-29ae-407a-837d-c39fef9fd790.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [22],\n  \"genders\": [\"F\"],\n  \"props\": [\"Minnie Mouse ears\", \"necklace\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"Cinderella Castle photo inspo.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [25],\n  \"genders\": [\"F\"],\n  \"props\": [\"bow\", \"bracelets\", \"bag\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"Cinderella Castle \ud83c\udff0.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [\n    22\n  ],\n  \"genders\": [\n    \"F\"\n  ],\n  \"props\": [\n    \"mouse ears\",\n    \"pin\"\n  ],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"Disneyland Paris.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [20],\n  \"genders\": [\n    \"F\"\n  ],\n  \"props\": [\n    \"Minnie Mouse ears\",\n    \"plush toy\",\n    \"bag\"\n  ],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"Disneyland.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [\n    25\n  ],\n  \"genders\": [\n    \"F\"\n  ],\n  \"props\": [\n    \"Mickey Mouse ears\",\n    \"purse\",\n    \"skirt\",\n    \"sweatshirt\",\n    \"sneakers\"\n  ],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"cfc8a062-bf9c-48d2-979f-cd2423378c09.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [22],\n  \"genders\": [\"F\"],\n  \"props\": [\"Mickey Mouse ears\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"disney world photo inspo.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [\n    22\n  ],\n  \"genders\": [\n    \"F\"\n  ],\n  \"props\": [\n    \"Mickey ears\"\n  ],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"disneyworld castle.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [25],\n  \"genders\": [\"F\"],\n  \"props\": [\"Minnie Mouse ears\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_447753227_438226109202069_4371849844253756843_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [28],\n  \"genders\": [\"F\"],\n  \"props\": [\"sunglasses\", \"Minnie Mouse ears\", \"bag\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_447784748_25902567832691526_4301790741281026502_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [25],\n  \"genders\": [\"F\"],\n  \"props\": [\"sunglasses\", \"Minnie Mouse ears\", \"bag\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_464772249_18463429120051262_8602433210822545224_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [20],\n  \"genders\": [\"F\"],\n  \"props\": [\"mouse ears\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_464920362_18463429177051262_126694318393601789_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [25],\n  \"genders\": [\"F\"],\n  \"props\": [\"mouse ears\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_464981431_18463429159051262_2533872068788557733_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [25],\n  \"genders\": [\"F\"],\n  \"props\": [],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_467019877_18372366811108367_3664847211782186911_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [22],\n  \"genders\": [\"F\"],\n  \"props\": [\"Minnie Mouse ears\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_468074638_18432982078074980_1436695365339519766_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [\n    25\n  ],\n  \"genders\": [\n    \"F\"\n  ],\n  \"props\": [\n    \"belt\",\n    \"sneakers\",\n    \"socks\"\n  ],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_473889928_18481907062033866_8581619210899793456_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [22],\n  \"genders\": [\"F\"],\n  \"props\": [\"Minnie Mouse ears\"],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  },
  {
    "parts": [
      {
        "text": "```json\n{\n  \"image_id\": \"downloadgram.org_481857154_18048263129202195_7827397574005691274_n.jpg\",\n  \"location_id\": \"Disney Castle\",\n  \"people_count\": 1,\n  \"ages\": [25],\n  \"genders\": [\n    \"F\"\n  ],\n  \"props\": [\n    \"sunglasses\",\n    \"Minnie Mouse ears\",\n    \"bag\"\n  ],\n  \"group_type\": \"single\"\n}\n```"
      }
    ],
    "role": "model"
  }
]

for obj in objs:
    new_obj = json.loads('\n'.join(obj['parts'][0]['text'].split('\n')[1:-1]))

    new_obj['image_path'] = new_obj['image_id']
    new_obj['place_title'] = new_obj['location_id']

    new_obj.pop('image_id')
    new_obj.pop('location_id')

    print(new_obj, ",")