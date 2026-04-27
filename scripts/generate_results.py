import re
from pathlib import Path
import os

import pandas as pd


def _read_csv_without_duplicates(path, sort_by):
    # Read the CSV file into a DataFrame
    df = pd.read_csv(path)
    # Drop duplicate rows
    df_unique = df.drop_duplicates().sort_values(by=sort_by)
    return df_unique


def read_statements(path):
    return _read_csv_without_duplicates(path, ['statementFile', 'statementLine'])


def read_bindings(path):
    return _read_csv_without_duplicates(path, ['statementFile', 'statementLine', 'bindingFile', 'bindingLine'])


def count_kinds(statement_df, binding_df):
    combined_df = pd.concat([statement_df, binding_df])
    return combined_df['kind'].value_counts().to_dict()


def count_statement_types(statement_df):
    # statement type is the first word of the `statementString`
    if 'statementString' in statement_df.columns:
        statement_df['statementType'] = 'sType:' + statement_df['statementString'].str.upper().str.split().str[0]
        statement_df.replace('sType:WITH', 'sType:SELECT', inplace=True)
        return statement_df['statementType'].value_counts().to_dict()
    else:
        return {}


def count_binding_types(binding_df):
    # binding type is the first word of the `key`
    if 'key' in binding_df.columns:
        binding_df['bindingType'] = 'bType:' + binding_df['key'].str.upper().str.split('.').str[0]
        return binding_df['bindingType'].value_counts().to_dict()
    else:
        return {}


def count_binding_keys(binding_df):
    if 'key' in binding_df.columns:
        binding_df['bindingKey'] = 'bKey:' + binding_df['key']
        return binding_df['bindingKey'].value_counts().to_dict()
    return {}


def write_clean_logs(project_path, dir):
    # Read CSVs
    s_csv_path = os.path.join(project_path, "statements.csv")
    b_csv_path = os.path.join(project_path, "bindings.csv")
    s_df = read_statements(s_csv_path)
    b_df = read_bindings(b_csv_path)

    # Get URL prefix from prefix.txt if it exists
    prefix_path = os.path.join(project_path, "prefix.txt")
    if os.path.exists(prefix_path):
        prefix = ""
        with open(prefix_path, "r") as f:
            prefix = f.read().strip()
        s_df['statementUrl'] = prefix + s_df['statementFile'] + "#L" + s_df['statementLine'].astype(str)
        b_df['statementUrl'] = prefix + b_df['statementFile'] + "#L" + b_df['statementLine'].astype(str)
        b_df['bindingUrl'] = prefix + b_df['bindingFile'] + "#L" + b_df['bindingLine'].astype(str)

    # Write cleaned CSVs
    os.makedirs(os.path.join(dir, project_path), exist_ok=True)
    s_df.to_csv(os.path.join(dir, project_path, "cleaned_statements.csv"), index=False)
    b_df.to_csv(os.path.join(dir, project_path, "cleaned_bindings.csv"), index=False)


def get_supported_bindings(b_df, supported_s_df):
    # filter bindings whose "statementFile", "statementLine" and "statemenColumn" correspond to a supported statement
    merge_columns = ['statementFile', 'statementLine', 'statementColumn']
    supported_b_df = b_df.merge(supported_s_df[merge_columns], on=merge_columns, how='inner')
    return supported_b_df


def generate_summary(paths):
    # Create single table with projects as rows and number of kinds as columns
    summary = {}
    for path in paths:
        s_csv_path = os.path.join(path, "statements.csv")
        b_csv_path = os.path.join(path, "bindings.csv")

        s_df = read_statements(s_csv_path)
        b_df = read_bindings(b_csv_path)

        if not os.path.exists(s_csv_path) or not os.path.exists(b_csv_path):
            raise FileNotFoundError(f"Both statements.csv and bindings.csv must exist in the directory {path}")

        kind_counts = count_kinds(s_df, b_df)
        summary[path] = kind_counts

        statement_type_counts = count_statement_types(s_df)
        summary[path].update(statement_type_counts)

        binding_type_counts = count_binding_types(b_df)
        summary[path].update(binding_type_counts)

        binding_key_counts = count_binding_keys(b_df)
        summary[path].update(binding_key_counts)

        supported_s_df = s_df[s_df['kind'] == 'SUPPORTED_PREPARED_STATEMENT']
        # supported_b_df = get_supported_bindings(b_df, supported_s_df)

        # Number of Statement/PreparedStatement statistics
        if 'isPreparedStatement' in supported_s_df.columns:
            # remove USING_FALLBACK rows
            dedup_df = s_df[s_df['kind'] != 'USING_FALLBACK']
            summary[path]['totalStatements'] = len(dedup_df)
            summary[path]['isPreparedStatement'] = dedup_df['isPreparedStatement'].value_counts().to_dict()[True]
            summary[path]['isRegularStatement'] = dedup_df['isPreparedStatement'].value_counts().to_dict().get(False, 0)

        # mean, median and max `numberOfParameters` per query
        if 'numberOfParameters' in supported_s_df.columns:
            # summary[path]['mean_parameters'] = supported_s_df['numberOfParameters'].mean()
            summary[path]['median_parameters'] = supported_s_df['numberOfParameters'].median()
            summary[path]['max_parameters'] = supported_s_df['numberOfParameters'].max()

        # mean, median and max length of `statementString` per query
        if 'statementString' in supported_s_df.columns:
            # summary[path]['mean_statement_length'] = supported_s_df['statementString'].str.len().mean()
            summary[path]['median_statement_length'] = supported_s_df['statementString'].str.len().median()
            summary[path]['max_statement_length'] = supported_s_df['statementString'].str.len().max()

    df = pd.DataFrame(summary).T.fillna(0).astype(int)
    # remove path prefix
    df.index = df.index.map(lambda x: re.split(r"[/\\]", x)[-1])

    return df


def collect_opslog(project_dir, project_name):
    print(f"Aggregating results for {project_name}...")

    base_path = Path(project_dir)
    statements_files = list(base_path.rglob("opslog*/statements.csv"))
    bindings_files = list(base_path.rglob("opslog*/bindings.csv"))

    if not statements_files:
        print(f"No statements files found for {project_name}. Skipping.")
        return

    if len(statements_files) > 1:
        print(f"Found {len(statements_files)} log dirs to merge.")

    try:
        df_statements = pd.concat((pd.read_csv(f) for f in statements_files), ignore_index=True)
        df_bindings = pd.concat((pd.read_csv(f) for f in bindings_files), ignore_index=True)
    except Exception as e:
        print(f"Error reading CSV files for {project_name}: {e}")
        return

    output_dir = Path("/artifact/data/generated/opslog") / project_dir.split("/")[-1]
    output_dir.mkdir(parents=True, exist_ok=True)
    df_statements.to_csv(output_dir / project_name / "statements.csv", index=False)
    df_bindings.to_csv(output_dir / project_name / "bindings.csv", index=False)


if __name__ == "__main__":
    projects = [
        ("projects/opennms/opennms-run", "OpenNMS (no annotations)"),
        ("projects/opennms/opennms-run-annos", "OpenNMS (annotated)"),
    ]

    for path, name in projects:
        collect_opslog(path, name)

    project_paths = [p[0] for p in projects]
    summary_df = generate_summary(project_paths)

    # write to CSV
    summary_df.to_csv("/artifact/data/generated/summary.csv", index_label="project")

    # write cleaned CSVs for each project
    for p in project_paths:
        write_clean_logs(p, "/artifact/data/generated/projects")