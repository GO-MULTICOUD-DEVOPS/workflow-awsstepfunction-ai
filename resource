#WorkFlow de uma automação de geração de sugestões utilizando o AWS STEP FUNCTIONS e a IA do AWS BEDROCK.

{
  "Comment": "An example of using Bedrock to chain prompts and their responses together.",
  "StartAt": "Pergunta: sugestção de comida",
  "States": {
    "Pergunta: sugestção de comida": {
      "Type": "Task",
      "Resource": "arn:aws:states:::bedrock:invokeModel",
      "Parameters": {
        "ModelId": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0",
        "Body": {
          "anthropic_version": "bedrock-2023-05-31",
          "max_tokens": 2000,
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Estou programando um jantar romântico, neste jantar irei pedir um macarrão, me dê uma lista de três ítens que combina em uma experiência gastronômica"
                }
              ]
            }
          ]
        },
        "ContentType": "application/json",
        "Accept": "*/*"
      },
      "Next": "Add first result to conversation history",
      "ResultPath": "$.result_one",
      "ResultSelector": {
        "result_one.$": "$.Body.content[0].text"
      }
    },
    "Add first result to conversation history": {
      "Type": "Pass",
      "Next": "Pergunta: sugestção de bebida",
      "Parameters": {
        "convo_one.$": "States.Format('{}\n{}', $.prompt_one, $.result_one.result_one)"
      },
      "ResultPath": "$.convo_one"
    },
    "Pergunta: sugestção de bebida": {
      "Type": "Task",
      "Resource": "arn:aws:states:::bedrock:invokeModel",
      "Parameters": {
        "ModelId": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0",
        "Body": {
          "anthropic_version": "bedrock-2023-05-31",
          "max_tokens": 2000,
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Liste duas bebidas que acompanhe um jantar romântico"
                }
              ]
            }
          ]
        },
        "ContentType": "application/json",
        "Accept": "*/*"
      },
      "Next": "Add second result to conversation history",
      "ResultSelector": {
        "result_two.$": "$.Body.content[0].text"
      },
      "ResultPath": "$.result_two"
    },
    "Add second result to conversation history": {
      "Type": "Pass",
      "Next": "Pergunta: sugestção de lugar",
      "Parameters": {
        "convo_two.$": "States.Format('{}\n{}\n{}', $.convo_one.convo_one, $.prompt_two, $.result_two.result_two)"
      },
      "ResultPath": "$.convo_two"
    },
    "Pergunta: sugestção de lugar": {
      "Type": "Task",
      "Resource": "arn:aws:states:::bedrock:invokeModel",
      "Parameters": {
        "ModelId": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0",
        "Body": {
          "anthropic_version": "bedrock-2023-05-31",
          "max_tokens": 2000,
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Liste um lugar perfeito para um jantar romântico em Paris "
                }
              ]
            }
          ]
        },
        "ContentType": "application/json",
        "Accept": "*/*"
      },
      "End": true,
      "ResultSelector": {
        "result_three.$": "$.Body.content[0].text"
      }
    }
  }
}