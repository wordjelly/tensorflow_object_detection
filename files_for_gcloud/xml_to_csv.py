import os
import glob
import pandas as pd
import xml.etree.ElementTree as ET
import sys

def xml_to_csv(path):
    xml_list = []
    for xml_file in glob.glob(path + '/*.xml'):
        tree = ET.parse(xml_file)
        root = tree.getroot()
        for member in root.findall('object'):
            print(xml_file)
            value = (root.find('filename').text,
                     int(root.find('size')[0].text),
                     int(root.find('size')[1].text),
                     member[0].text,
                     int(member[4][0].text),
                     int(member[4][1].text),
                     int(member[4][2].text),
                     int(member[4][3].text)
                     )
            xml_list.append(value)
    column_name = ['filename', 'width', 'height', 'class', 'xmin', 'ymin', 'xmax', 'ymax']
    xml_df = pd.DataFrame(xml_list, columns=column_name)
    return xml_df

def main(xml_folder,output_csv_file_name):
    xml_labels_path = os.path.join(xml_folder[0])
    xml_df = xml_to_csv(xml_labels_path)
    xml_df.to_csv(output_csv_file_name[0], index=None)
    print('Successfully converted xml to csv.')

main(sys.argv[1:],sys.argv[2:])
