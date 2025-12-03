import torch
import librosa
import numpy as np
from transformers import WhisperProcessor
from voice_finder.model import VoiceEmbedder
import os
from pathlib import Path

# --- Configuración del Modelo (igual a tu prueba_embedding.py) ---
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Usando dispositivo: {device}")

# Cargar modelo y procesador
model = VoiceEmbedder.from_pretrained("johbac/voice-embedder-base").to(device)
model.eval()
processor = WhisperProcessor.from_pretrained("openai/whisper-base")

# --- Funciones de Preprocesamiento (de tu prueba_embedding.py) ---
def preprocess_audio_to_mel(file_path, target_sr=16000, target_length=1000):
    try:
        audio, sr = librosa.load(file_path, sr=target_sr, mono=True)
    except Exception as e:
        print(f"Error cargando {file_path}: {e}")
        return None

    inputs = processor.feature_extractor(
        audio,
        sampling_rate=target_sr,
        return_tensors="pt",
        padding="longest"
    )
    mel = inputs.input_features
    mel_len = mel.shape[-1]

    if mel_len < target_length:
        pad_size = target_length - mel_len
        mel = torch.nn.functional.pad(mel, (0, pad_size))
    elif mel_len > target_length:
        mel = mel[:, :, :target_length]
    
    return mel.to(device)

def extract_embedding(file_path):
    mel_features = preprocess_audio_to_mel(file_path)
    if mel_features is None:
        return None
    
    with torch.no_grad():
        embedding = model(mel_features)
    return embedding.cpu().numpy().squeeze()

# --- Lógica Principal: Procesar tu directorio ---
def process_audio_directory(root_dir):
    embeddings_list = []
    labels_list = []
    
    # Usamos Pathlib para encontrar todos los audios y obtener el nombre de la carpeta
    audio_files = list(Path(root_dir).rglob("*.wav"))
    
    if not audio_files:
        print(f"Error: No se encontraron archivos .wav en {root_dir}")
        print("Asegúrate de que la ruta es correcta y tus archivos son .wav")
        return

    print(f"Encontrados {len(audio_files)} archivos. Procesando...")

    for i, file_path in enumerate(audio_files):
        # El nombre de la persona es el nombre de la carpeta padre
        label = file_path.parent.name
        
        print(f"Procesando ({i+1}/{len(audio_files)}): {file_path.name} (Persona: {label})")
        
        embedding = extract_embedding(file_path)
        
        if embedding is not None:
            embeddings_list.append(embedding)
            labels_list.append(label)

    # Convertir listas a arrays de NumPy
    embeddings_array = np.array(embeddings_list)
    labels_array = np.array(labels_list)
    
    # Guardar los archivos
    np.save("embeddings.npy", embeddings_array)
    np.save("labels.npy", labels_array)
    
    print("\n¡Proceso completado!")
    print(f"Embeddings guardados en 'embeddings.npy' (Shape: {embeddings_array.shape})")
    print(f"Etiquetas guardadas en 'labels.npy' (Shape: {labels_array.shape})")

if __name__ == "__main__":
    # 1. ESTA LÍNEA ESTÁ CORRECTA. La dejaste bien.
    RUTA_AUDIOS = "C:\\Users\\Jesus\\OneDrive\\copia de seguridad\\Escritorio\\Repositorios de Jesus Felix\\CursosDeHTMl\\ProyectoFinal\\AUDIOS _SIN_TRATAMIENTO" 
    
    # 2. ESTA LÍNEA LA REGRESAMOS A SU ORIGINAL.
    # Comprueba si la ruta sigue siendo el texto de ejemplo.
    if RUTA_AUDIOS == "C:\\Users\\Jesus\\OneDrive\\copia de seguridad\\Escritorio\\Repositorios de Jesus Felix\\CursosDeHTMl\\ProyectoFinal\\AUDIOS _SIN_TRATAMIENTO":
        print("¡Error! Por favor, edita la variable 'RUTA_AUDIOS' en el script.")
    else:
        # Como tu ruta ya no es "PON_AQUI...", el script 
        # saltará aquí y ejecutará la función.
        process_audio_directory(RUTA_AUDIOS)