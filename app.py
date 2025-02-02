import streamlit as st
import subprocess
import os
from pathlib import Path

st.set_page_config(layout="centered", page_title="GeneFlow", page_icon="🧬")
# add a title on the page

st.title("GeneFlow")

st.write("Please provide the paths to the files and select the appropriate options for your RNA-Seq analysis.")

# Create two columns for layout
col1, col2 = st.columns([1, 3])  # Ratio of 1 for image column and 3 for content column

with col1:
    st.image("./dna.jpg", use_container_width=True)

# Column 2: Right side for the input fields and other elements
with col2:
    # Input fields for the required paths
    workdir = st.text_input('Working Directory', placeholder='/path/to/working_directory', help="The directory where your analysis will take place.")
    reference_index = st.text_input('Path to Reference Index', placeholder='/path/to/reference_index', help="The path to the reference genome index (e.g., hg38).")
    fastq_path = st.text_input('Path to FASTQ file', placeholder='/path/to/fastq', help="The path to your input FASTQ file.")
    annotations_path = st.text_input('Path to Annotations', placeholder='/path/to/annotations', help="The path to your gene annotation file.")
    strand_specificity = st.selectbox('Strand Specificity', ['None', 'RF', 'FR'], help="Select the strand specificity for your RNA-Seq data.")

    if st.button('Run Analysis'):
        if not all([workdir, reference_index, fastq_path, annotations_path]):
            st.error("Please provide all the required parameters!")
        else:
            if not Path(workdir).exists():
                st.error(f"Error: Working directory '{workdir}' does not exist.")
            elif not Path(fastq_path).exists():
                st.error(f"Error: FASTQ file '{fastq_path}' does not exist.")
            elif not Path(reference_index).exists():
                st.error(f"Error: Reference index directory '{reference_index}' does not exist.")
            elif not Path(annotations_path).exists():
                st.error(f"Error: Annotations file '{annotations_path}' does not exist.")
            else:
                with st.spinner("Running analysis... This may take a while. Please wait."):
                    try:
                        #ensure the script is executable
                        subprocess.run("chmod +x pipeline.sh", shell=True)
                        # Build the bash command
                        bash_command = f"./pipeline.sh {workdir} {reference_index} {fastq_path} {annotations_path} {strand_specificity}"

                        # Run the script and capture the output
                        result = subprocess.run(bash_command, shell=True, text=True, capture_output=True)

                        if result.returncode == 0:
                            st.success("Analysis Complete!")
                            st.text(result.stdout)  # Output the log of the script run

                            # After analysis, check if the feature counts file exists
                            feature_counts_path = os.path.join(workdir, "data", "feature_counts.txt")
                            if Path(feature_counts_path).exists():
                                st.subheader("Gene Counts:")
                                with open(feature_counts_path, "r") as f:
                                    st.text(f.read())  # Display the content of feature counts

                                # Provide a download link for the feature counts file
                                st.download_button(
                                    label="Download Gene Counts (feature_counts.txt)",
                                    data=open(feature_counts_path, "rb").read(),
                                    file_name="feature_counts.txt",
                                    mime="text/plain"
                                )
                            else:
                                st.error("Feature counts file not found.")

                        else:
                            st.error(f"Error occurred: {result.stderr}")

                    except Exception as e:
                        st.error(f"An error occurred: {str(e)}")
