############################################################################################################
# Code for the paper: Large Language Models for Scientific Synthesis, Inference and Explanation
# Code Authors: Yizhen Zheng, Huan Yee Koh, Jiaxin Ju
# https://github.com/zyzisastudyreallyhardguy/LLM4SD/tree/main
#
# * Please install packages in requirment.txt before running this file
# 
# * To automate the entire process, we recommend utilizing GPT-4-turbo for summarizing inference rules and
# generating the corresponding code. Please ensure you have entered your API_KEY before initiating the run.
############################################################################################################

# API Configuration
API_KEY='' # OpenAI API key or Azure OpenAI API key for summarization and code generation

# Azure OpenAI Configuration (leave empty to use standard OpenAI)
AZURE_ENDPOINT='' # Azure OpenAI endpoint URL (e.g., 'https://your-resource.openai.azure.com')
AZURE_API_VERSION='2023-05-15' # Azure OpenAI API version
AZURE_DEPLOYMENT='' # Azure OpenAI deployment name for GPT-4

MODEL="galactica-6.7b" # ("falcon-40b" "galactica-30b" "chemdfm" "chemllm-7b") Falcon-7B fails in qm9 tasks
# Generated content from "chemllm-7b" for inference.py may not meet the required standards for proceeding directly to Step 4.
# It is strongly recommended that you thoroughly review the rules qualities before running step 4.

QM9_SUBTASK=("alpha" "c_v" "Delta_epsilon" "epsilon_HOMO" "epsilon_LUMO" "G" "H" "mu" "R^2" "U_0" "U" "ZPVE")


# Step 1: Generate prior knowledge and data knowledge prompt json file
# Please mannually add your own prompt if your task is not in the above dataset list
echo "Processing step 1: Generating Prompt files ..."
python create_prompt.py --task synthesize
python create_prompt.py --task inference

# Processing Sider Dataset
echo "Processing QM9 dataset ..."
for subtask in "${QM9_SUBTASK[@]}"; do
    #Step 2: Extract rules from prior knowledge
    echo "Processing step 2 for QM9-$subtask: LLM for Scientific Synthesize"
    python synthesize.py --dataset ${subtask} --subtask "" --model ${MODEL} --output_folder "synthesize_model_response"
    
    # Step 3: Knowledge inference from Data
    # We only run --list_num 50 for QM9 dataset
    echo "Processing step 3 for QM9-$subtask: LLM for Scientific Inference"
    python inference.py --dataset ${subtask} --subtask "" --model ${MODEL} --list_num 50 --output_folder "inference_model_response"
    
    # Step 4: Summarize inference rules generated from the last step
    echo "Processing step 4 for QM9-$subtask: Summarize rules from gpt4"
    python summarize_rules.py --input_model_folder ${MODEL} --dataset qm9 --subtask ${subtask} --list_num 50 --api_key ${API_KEY} \
                              --azure_endpoint ${AZURE_ENDPOINT} --azure_api_version ${AZURE_API_VERSION} --azure_deployment ${AZURE_DEPLOYMENT} \
                              --output_folder "summarized_inference_rules"

    # Step 5: Interpretable model training and Evaluation
    # Results in our paper are stored in eval_result folder and the generated code files are in eval_code_generation_repo folder
    # To avoid overwriting we here provide another folder name
    # **** Must run synthesize and inference setting before run all setting ****
    echo "Processing step 5 for QM9-$subtask: Interpretable model training and Evaluation"
    python code_gen_and_eval.py --dataset qm9 --subtask ${subtask} --model ${MODEL} --knowledge_type "synthesize" \
                                --api_key ${API_KEY} --azure_endpoint ${AZURE_ENDPOINT} --azure_api_version ${AZURE_API_VERSION} --azure_deployment ${AZURE_DEPLOYMENT} \
                                --output_dir "llm4sd_results" --code_gen_folder "llm4sd_code_generation"
    
    python code_gen_and_eval.py --dataset qm9 --subtask ${subtask} --model ${MODEL} --knowledge_type "inference" --list_num 50 \
                                --api_key ${API_KEY} --azure_endpoint ${AZURE_ENDPOINT} --azure_api_version ${AZURE_API_VERSION} --azure_deployment ${AZURE_DEPLOYMENT} \
                                --output_dir "llm4sd_results" --code_gen_folder "llm4sd_code_generation"
    
    python code_gen_and_eval.py --dataset qm9 --subtask ${subtask} --model ${MODEL} --knowledge_type "all" --list_num 50 \
                                --api_key ${API_KEY} --azure_endpoint ${AZURE_ENDPOINT} --azure_api_version ${AZURE_API_VERSION} --azure_deployment ${AZURE_DEPLOYMENT} \
                                --output_dir "llm4sd_results" --code_gen_folder "llm4sd_code_generation"
done