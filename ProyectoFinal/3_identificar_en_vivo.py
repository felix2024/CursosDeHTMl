import torch
import librosa
import numpy as np
from transformers import WhisperProcessor
from voice_finder.model import VoiceEmbedder
import joblib
import sounddevice as sd
import soundfile as sf
import time

# --- Configuración del Modelo (Embedding) ---
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Usando dispositivo: {device}")

# Cargar modelo y procesador de embeddings
embedder_model = VoiceEmbedder.from_pretrained("johbac/voice-embedder-base").to(device)
embedder_model.eval()
processor = WhisperProcessor.from_pretrained("openai/whisper-base")

# --- Cargar Modelo Entrenado (SVM o MLP) ---
# Elige qué modelo quieres usar para la demo en vivo:
MODELO_A_USAR = "modelo_svm.joblib"  # O cambia a "modelo_mlp.joblib"

try:
    classifier_model = joblib.load(MODELO_A_USAR)
    label_encoder = joblib.load('label_encoder.joblib')
except FileNotFoundError:
    print("Error: No se encontraron los archivos del modelo (.joblib).")
    print("Asegúrate de ejecutar '2_entrenar_evaluar.py' primero.")
    exit()

print(f"Modelo de clasificación '{MODELO_A_USAR}' cargado.")
print(f"Clases conocidas: {label_encoder.classes_}")

# --- Funciones de Preprocesamiento (Copiadas de los otros scripts) ---
def preprocess_audio_to_mel(audio_array, target_sr=16000, target_length=1000):
    # La entrada ya es un array de numpy, no una ruta de archivo
    inputs = processor.feature_extractor(
        audio_array,
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

def extract_embedding_from_array(audio_array):
    mel_features = preprocess_audio_to_mel(audio_array)
    if mel_features is None:
        return None
    with torch.no_grad():
        embedding = embedder_model(mel_features)
    return embedding.cpu().numpy() # No hacemos squeeze, el modelo espera (1, D)

# --- Lógica de Grabación e Identificación ---
def record_and_identify(duration=6, sr=16000):
    print("\nHabla ahora...")
    
    # Grabar audio
    audio_data = sd.rec(int(duration * sr), samplerate=sr, channels=1, dtype='float32')
    
    # Cuenta regresiva
    for i in range(duration, 0, -1):
        print(f"{i}...")
        time.sleep(1)
    sd.wait()  # Esperar a que la grabación termine
    
    print("Procesando...")
    
    # Aplanar el audio (por si acaso) y asegurarse que es 1D
    audio_data = audio_data.flatten()
    
    # 1. Extraer el embedding del audio grabado
    embedding = extract_embedding_from_array(audio_data)
    
    if embedding is None:
        print("No se pudo extraer el embedding.")
        return

    # 2. Predecir con el clasificador
    # Usamos predict_proba para obtener la confianza
    prediction_probs = classifier_model.predict_proba(embedding)[0]
    
    # 3. Obtener la clase (el número) con mayor probabilidad
    predicted_class_index = np.argmax(prediction_probs)
    
    # 4. Obtener la confianza
    confidence = prediction_probs[predicted_class_index]
    
    # 5. Convertir el número de clase al nombre de la persona
    predicted_person = label_encoder.inverse_transform([predicted_class_index])[0]
    
    print("\n--- ¡Identificación Completa! ---")
    print(f"Persona detectada: **{predicted_person}**")
    print(f"Confianza: **{confidence * 100:.2f}%**")

if __name__ == "__main__":
    print("Iniciando identificador de voz en tiempo real.")
    print("Presiona Enter para grabar y detectar, o escribe 'salir' para terminar.")
    
    while True:
        user_input = input("\n¿Listo para grabar? (Enter/salir): ")
        if user_input.lower() == 'salir':
            break
        record_and_identify()