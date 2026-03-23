# FirstChatbotApp

## Why this repo
This is just a public journey of learning how to code agentic, and chatbot apps. My goal is to be able to understand traceability, observability, learn to code agents, tool calling, prompt guiding (idk if that is a real thing but i want to be able to use prompts as guard rails), and more topics i have recently been learning about.

**This readme will be updated each time i learn something new, and will work as a "diary" of some sort, to be able to document all my findings, and possible thoughts or vision of the app throughout the development lifecycle.**

**Disclaimer:** Im using AI to learn and guide me. this means you may see some AI generated Labels or comments, but everything in the readme is written by me. Im using ai to build a little quicker, and also to be able to understand things that are not as obvious or clear to me a little faster.

### Day 1:
- learning to use LangFuse
- Putting into action learnt python backend for AI calling
- Will be learning Langchain as an alternative, i want to see if its better to use openai's package or an "abstracted" package.

for now, i will stick to openai's package, to learn the basics. i want to understand what is REALLY going on.

This will be paired with LangFuse to be able to have traceability and observability of the app, and to be able to learn how to use the dashboard it as well. 

what I've learnt, is that using LangFuse is easier than thought, it basically has no configuration or learning curve. What is a little more complex, is understanding the traces, and how to use them to **iterate** on the agent and be able to make it better.

### Day 2:
- learning to use gradio to build a simple chatbot interface, and connect it to openai python module
- learning to add history to conversations, that way it can remember messages sent by the user
- learning to trim history, that way it can only remember the last 4 messages, and not get confused by old messages that are not relevant anymore

It was a bit tricky to understand how to use gradio, and how to connect it to openai, but after some trial and error, i was able to build a simple chatbot interface that can remember the last 4 messages sent by the user, and respond accordingly. it has both versions, no trim mode, and trim mode.

Next i will try to build a more complex agent, that can call some tools, and also log these tool calls and also have more traceability on lang fuse.

### Day 3 +
Since i think i got the basics down, i will be building a basic chat app, just to test how building an API is like, with open ai python module.

the purpose of this, is getting more in line with production ready software, which will not use gradio, but instead use notebooks as tests and validations, and logic will actually be used for the api instead of being directly in the gradio interface.

It will use fast API for the backend, and Flutter for mobile, desktop and web frontend. 