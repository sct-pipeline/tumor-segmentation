# This script serves to reorganize the data from /usr/Spinal_Cord_Data/Tumor into BIDS dataset
# located under /usr/Spinal_Cord_Data/Tumor_BIDS
# To use simply call python BIDS_data_china -d /usr/Spinal_Cord_Data/Tumor
# Created by: Alexandru Foias 

import os,shutil,re,json,csv,argparse

def get_parameters():
    parser = argparse.ArgumentParser(description='This script is used for '
                                     'aranging sct_large into BIDS compatible mode')
    parser.add_argument("-d", "--data",
                        help="Path to dataset directory",
                        required=True)
    args = parser.parse_args()
    return args

def main(path_data):
    """
    Main function
    :param path_data:
    :return:
    """
    #Define filenames & paths
    rootDataPath = path_data
    rootBIDSDataPath_init = '/'.join(rootDataPath.split('/')[0:-1])
    rootBIDSDataPath = rootBIDSDataPath_init + '/' + rootDataPath.split('/')[-1] + '_BIDS'
    dataset_description_jsonFILENAME = os.path.join(rootBIDSDataPath, 'dataset_description.json')
    participants_jsonFILENAME = os.path.join(rootBIDSDataPath,'participants.json')
    participants_tsvFILENAME = os.path.join(rootBIDSDataPath, 'participants.tsv')

    if not os.path.isdir(rootBIDSDataPath):
        os.mkdir(rootBIDSDataPath)

    img_dict = {'_T1_manual_lesion_label.nii.gz':('_T1w_seg-tumor.nii.gz','derivatives/labels'),
                '_T2_manual_lesion_label.nii.gz':('_T2w_seg-tumor.nii.gz','derivatives/labels'),
                '_T1w.nii.gz':('_T1w.nii.gz',''),
                '_T2w.nii.gz':('_T2w.nii.gz',''),
                }
    #Rearrange data into BIDS format
    for cwd, dirs, files in os.walk(rootDataPath):
        for file in files:
            file_path = os.path.join(cwd,file)
            
            for img_key in img_dict.keys():
                if file.endswith(img_key):
                    sub_full = str(file.split('_')[0])
                    sub_id = (re.findall('\d+', sub_full ))
                    sub_type = cwd.split('/')[-3].split('_')[0][0:4]
                    sub_id_new = "sub-"+ sub_type + sub_id[0]
                    sub_new_folder = os.path.join(rootBIDSDataPath,img_dict[img_key][1],sub_id_new , "anat")
                    if not os.path.exists(sub_new_folder):
                        os.makedirs(sub_new_folder)
                    new_file_path = os.path.join(sub_new_folder, sub_id_new + img_dict[img_key][0])
                    print ("Initial path: " + file_path)
                    print ("New path:     " + new_file_path + '\n')
                    shutil.copy(file_path,new_file_path)

    #Create participants.json
    content_participants_json = [
            {
                "participant_id": {
                    "LongName": "Participant ID",
                    "Description": "Unique ID"
                },
                "sex": {
                    "LongName": "Participant gender",
                    "Description": "M or F"
                },
                "age": {
                    "LongName": "Participant age",
                    "Description": "yy"
                }
                }]
    # Save participants.json
    with open(participants_jsonFILENAME, 'w') as outfile:
        outfile.write(json.dumps(content_participants_json[0], indent=2))
        outfile.close()

    #Create dataset_description.json
    dataset_description = {}
    dataset_description[u'Name'] = 'SCT_Tumor'
    dataset_description[u'BIDSVersion'] = '1.2.1'

    # Save dataset_description.json
    with open(dataset_description_jsonFILENAME, 'w') as outfile:
        outfile.write(json.dumps(dataset_description,
                                    indent=2, sort_keys=True))
        outfile.close()
    participants =[]
    #Create participants.tsv
    for dirs in os.listdir(rootBIDSDataPath):
        if dirs.startswith('sub-'):
            row_participants = []
            row_participants.append(dirs)
            row_participants.append('-')
            row_participants.append('-')
            participants.append(row_participants)
            
    # # Save participants.tsv
    with open(participants_tsvFILENAME, 'w') as tsv_file:
        tsv_writer = csv.writer(tsv_file, delimiter='\t', lineterminator='\n')
        tsv_writer.writerow(["participant_id", "sex", "age"])
        for item in participants:
            tsv_writer.writerow(item)
    #Export sidecar json 
    for cwd, dirs, files in os.walk(rootBIDSDataPath):
        for file in files:
            if file.endswith('.nii.gz'):
                    currentFilePath = os.path.join(cwd + '/' + file)
                    jsonAdjPath = os.path.join(cwd + '/' + file.split('.')[0]+'.json')
                    if os.path.exists(os.path.join(cwd + '/' + file.split('.')[0]+'.json'))==False:
                        print ('Warning - Missing: ' +  jsonAdjPath)
                        os.system('touch ' + jsonAdjPath)
if __name__ == "__main__":
    args = get_parameters()
    main(args.data)