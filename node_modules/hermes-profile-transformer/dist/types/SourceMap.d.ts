export interface SourceMap {
    version: string;
    sources: string[];
    sourceContent: string[];
    x_facebook_sources: {
        names: string[];
        mappings: string;
    }[] | null;
    names: string[];
    mappings: string;
}
